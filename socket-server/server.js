const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('./database');

const app = express();
const JWT_SECRET = 'im a chud';

app.use(express.json());

// ---- Auth middleware ----
/*
function authenticate(req, res, next) {
    const header = req.headers.authorization;
    if (!header) return res.status(401).json({ success: false, message: 'No token provided' });

    const token = header.split(' ')[1];

    try {
        req.user = jwt.verify(token, JWT_SECRET);
        next();
    } catch {
        res.status(401).json({ success: false, message: 'Session expired' });
    }
}
*/
app.get('/me', (req, res) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const user = db.prepare('SELECT * FROM users WHERE userId = ?').get(decoded.userId);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });

        res.json({ success: true });
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({success: false, message: 'Token expired'});
        }
    }

    return res.status(403).json({ success: false, message: 'Invalid token' });
});

// ---- Auth routes ----
app.post('/sign-up', async (req, res) => {
    const { username, password } = req.body;
    if (!username) {
        return res.status(400).json({ success: false, message: 'Username required' });
    }

    if (!password) {
        return res.status(400).json({ success: false, message: 'Password required' });
    }

    if (username.length < 5) {
        return res.status(400).json({ success: false, message: 'Username too short' });
    }

    if (username.length > 15) {
        return res.status(400).json({ success: false, message: 'Username too long' });
    }

    if (password.length < 8) {
        return res.status(400).json({ success: false, message: 'Password too short' });
    }

    if (password.length > 32) {
        return res.status(400).json({ success: false, message: 'Password too long' });
    }

    const hash = await bcrypt.hash(password, 10);
    try {
        db.prepare('INSERT INTO users (username, password) VALUES (?, ?)').run(username, hash);
        // GENERATE AND RETURN TOKEN
        const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
        const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ success: true, token });
    } catch (error) {
        console.log('Actual error: ' + error.message);
        res.status(409).json({ success: false, message: 'Username already taken' });
    }
});

app.post('/sign-in', async (req, res) => {
    const { username, password } = req.body;
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
    if (!user) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '7d' });

    res.json({ success: true, token });
});

// ---- Toilet routes ----
app.get('/get-toilets', (req, res) => {
    const toilets = db.prepare(`
    SELECT toilets.*, users.username AS userCreator
    FROM toilets
    JOIN users ON toilets.userId = users.userId`).all();
    res.json({success: true, toilets});
});

/*
app.get('/toilets/:id', (req, res) => {
    const toilet = db.prepare(`
    SELECT toilets.*, users.username AS userCreator
    FROM toilets
    JOIN users ON toilets.userId = users.userId
    WHERE toilets.id = ?
  `).get(req.params.id);

    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });

    const reviews = db.prepare(`
    SELECT reviews.*, users.username
    FROM reviews
    JOIN users ON reviews.user_id = users.id
    WHERE reviews.toilet_id = ?
    ORDER BY reviews.created_at DESC
  `).all(req.params.id);

    res.json({ success: true, ...toilet, reviews });
});
*/

app.post('/create-toilet', (req, res) => {
    const { toiletName, description, latitude, longitude } = req.body;
    const token = req.headers['authorization']?.split(' ')[1];

    if (!toiletName) {
        return res.status(400).json({ success: false, message: 'No toilet name' });
    }

    if (!description) {
        return res.status(400).json({ success: false, message: 'No description' });
    }

    if (!latitude) {
        return res.status(400).json({ success: false, message: 'No latitude' });
    }

    if (!longitude) {
        return res.status(400).json({ success: false, message: 'No longitude' });
    }

    try {
        const result = db.prepare(`
        INSERT INTO toilets (userId, toiletName, description, latitude, longitude, avgStar)
        VALUES (?, ?, ?, ?, ?, ?)`).run(jwt.verify(token, JWT_SECRET).userId, toiletName, description, latitude, longitude, 0);

        res.json({ success: true });
    } catch {
        res.json({ success: false, message: 'Toilet already exists' });
    }
});

app.delete('/delete-toilet', (req, res) => {
    const {toiletId} = req.body;
    const token = req.headers['authorization']?.split(' ')[1];
    const toilet = db.prepare('SELECT * FROM toilets WHERE toiletId = ?').get(toiletId);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });
    if (toilet.userId !== jwt.verify(token, JWT_SECRET).userId) {
        return res.status(403).json({ success: false, message: 'Not your toilet to delete' });
    }

    db.prepare('DELETE FROM toilets WHERE toiletId = ?').run(toiletId);
    res.json({ success: true, message: 'Toilet deleted' });
});

// ---- Review routes ----
app.post('/create-review', (req, res) => {
    const { toiletId, star, title, description } = req.body;
    if (!star) return res.status(400).json({ success: false, message: 'Rating required' });
    if (!title) return res.status(400).json({ success: false, message: 'Title required' });
    if (!description) return res.status(400).json({ success: false, message: 'Description required' });

    const token = req.headers['authorization']?.split(' ')[1];

    const toilet = db.prepare('SELECT * FROM toilets WHERE toiletId = ?').get(toiletId);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });

    const existing = db.prepare(
        'SELECT * FROM reviews WHERE toiletId = ? AND userId = ?').get(toiletId, jwt.verify(token, JWT_SECRET).userId);
    if (existing) {
        return res.status(409).json({ success: false, message: 'You already reviewed this toilet' });
    }

    const result = db.prepare(`
    INSERT INTO reviews (toiletId, userId, star, title, description )
    VALUES (?, ?, ?, ?, ?)`).run(toiletId, jwt.verify(token, JWT_SECRET).userId, star, title, description);

    const { avgStar } = db.prepare('SELECT ROUND(AVG(star), 1) as avgStar FROM reviews WHERE toiletId = ?').get(toiletId);
    db.prepare('UPDATE toilets SET avgStar = ? WHERE toiletId = ?').run(avgStar, toiletId);

    res.json({ success: true} );
});

app.delete('/delete-review', (req, res) => {
    const {reviewId} = req.body;
    const token = req.headers['authorization']?.split(' ')[1];

    const review = db.prepare('SELECT * FROM reviews WHERE reviewId = ?').get(reviewId);
    if (!review) return res.status(404).json({ success: false, message: 'Review not found' });
    if (review.userId !== jwt.verify(token, JWT_SECRET).userId) {
        return res.status(403).json({ success: false, message: 'Not your review to delete' });
    }

    db.prepare('DELETE FROM reviews WHERE reviewId = ?').run(reviewId);

    const { toiletId } = review;
    const { avgStar } = db.prepare('SELECT ROUND(AVG(star), 1) as avgStar FROM reviews WHERE toiletId = ?').get(toiletId);
    db.prepare('UPDATE toilets SET avgStar = ? WHERE toiletId = ?').run(avgStar, toiletId);

    res.json({ success: true });
});

app.get('/get-users', (req, res) => {
    try {
        const users = db.prepare('SELECT userId, username FROM users').all();
        res.json({success: true, users});
    } catch {
        res.status(400).json({success: false, message: 'No users found'})
    }
})

app.get('/get-reviews', (req, res) => {
    try {
        const reviews = db.prepare('SELECT * FROM reviews').all();
        res.json({success: true, reviews});
    } catch {
        res.status(400).json({success: false, message: 'No reviews found'})
    }
})

// ---- Start server ----
app.listen(3000, () => {
    console.log('Server running on :3000');
});
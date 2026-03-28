const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('./database');

const app = express();
const JWT_SECRET = 'change-this-to-something-long-and-random';

app.use(express.json());

// ---- Auth middleware ----
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

// ---- Auth routes ----
app.post('/sign-up', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ success: false, message: 'Username and password required' });
    }

    const hash = await bcrypt.hash(password, 10);
    try {
        db.prepare('INSERT INTO users (username, password) VALUES (?, ?)').run(username, hash);
        res.json({ success: true, message: 'User created' });
    } catch (error) {
        console.log('Actual error: ' + error.message);
        res.status(409).json({ success: false, message: 'Username already taken' });
    }
});

app.post('/login', async (req, res) => {
    const { username, password } = req.body;
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
    if (!user) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ id: user.id, username: user.username }, JWT_SECRET, {
        expiresIn: '7d',
    });

    res.json({ success: true, token });
});

// ---- Toilet routes ----
app.get('/toilets', (req, res) => {
    const toilets = db.prepare(`
    SELECT toilets.*, users.username AS added_by_username
    FROM toilets
    JOIN users ON toilets.added_by = users.id
  `).all();
    res.json({success: true, toilets});
});

app.get('/toilets/:id', (req, res) => {
    const toilet = db.prepare(`
    SELECT toilets.*, users.username AS added_by_username
    FROM toilets
    JOIN users ON toilets.added_by = users.id
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

app.post('/toilets', authenticate, (req, res) => {
    const { name, latitude, longitude, address } = req.body;
    if (!name || latitude == null || longitude == null) {
        return res.status(400).json({ success: false, message: 'Name, latitude, and longitude required' });
    }

    const result = db.prepare(`
    INSERT INTO toilets (name, latitude, longitude, address, added_by)
    VALUES (?, ?, ?, ?, ?)
  `).run(name, latitude, longitude, address || null, req.user.id);

    res.json({ success: true, id: result.lastInsertRowid, message: 'Toilet added' });
});

app.delete('/toilets/:id', authenticate, (req, res) => {
    const toilet = db.prepare('SELECT * FROM toilets WHERE id = ?').get(req.params.id);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });
    if (toilet.added_by !== req.user.id) {
        return res.status(403).json({ success: false, message: 'Not your toilet to delete' });
    }

    db.prepare('DELETE FROM toilets WHERE id = ?').run(req.params.id);
    res.json({ success: true, message: 'Toilet deleted' });
});

// ---- Review routes ----
app.post('/toilets/:id/reviews', authenticate, (req, res) => {
    const { rating, comment } = req.body;
    if (!rating) return res.status(400).json({ success: false, message: 'Rating required' });

    const toilet = db.prepare('SELECT * FROM toilets WHERE id = ?').get(req.params.id);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });

    const existing = db.prepare(
        'SELECT * FROM reviews WHERE toilet_id = ? AND user_id = ?'
    ).get(req.params.id, req.user.id);
    if (existing) {
        return res.status(409).json({ success: false, message: 'You already reviewed this toilet' });
    }

    const result = db.prepare(`
    INSERT INTO reviews (toilet_id, user_id, rating, comment)
    VALUES (?, ?, ?, ?)
  `).run(req.params.id, req.user.id, rating, comment || null);

    res.json({ success: true, id: result.lastInsertRowid, message: 'Review added' });
});

app.delete('/reviews/:id', authenticate, (req, res) => {
    const review = db.prepare('SELECT * FROM reviews WHERE id = ?').get(req.params.id);
    if (!review) return res.status(404).json({ success: true, message: 'Review not found' });
    if (review.user_id !== req.user.id) {
        return res.status(403).json({ success: true, message: 'Not your review to delete' });
    }

    db.prepare('DELETE FROM reviews WHERE id = ?').run(req.params.id);
    res.json({ success: true, message: 'Review deleted' });
});

app.get('/users/:id/reviews', (req, res) => {
    const reviews = db.prepare(`
    SELECT reviews.*, toilets.name AS toilet_name
    FROM reviews
    JOIN toilets ON reviews.toilet_id = toilets.id
    WHERE reviews.user_id = ?
    ORDER BY reviews.created_at DESC
  `).all(req.params.id);

    res.json({success: true, reviews});
});

app.get('/users', (req, res) => {
    const users = db.prepare('SELECT user_id, username FROM users').all();
    res.json({success: true, users});
})

// ---- Start server ----
app.listen(3000, () => console.log('Server running on :3000'));
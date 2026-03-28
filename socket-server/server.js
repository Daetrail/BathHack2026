const express = require('express');
const jwt = require('jsonwebtoken');
const bcrypt = require('bcrypt');
const db = require('./database');

const app = express();
const JWT_SECRET = 'im a chud';

app.use(express.json());

// ---- Helper: extract userId from JWT in Authorization header ----
function getUserIdFromToken(req) {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return null;
    try {
        return jwt.verify(token, JWT_SECRET).userId;
    } catch {
        return null;
    }
}

// ---- Auth: verify current session ----
app.get('/me', (req, res) => {
    const token = req.headers['authorization']?.split(' ')[1];
    if (!token) return res.status(401).json({ success: false, message: 'No token provided' });

    try {
        const decoded = jwt.verify(token, JWT_SECRET);
        const user = db.prepare('SELECT userId, username FROM users WHERE userId = ?').get(decoded.userId);
        if (!user) return res.status(404).json({ success: false, message: 'User not found' });

        // Return username so the app knows who's logged in
        return res.json({ success: true, username: user.username });
    } catch (error) {
        if (error.name === 'TokenExpiredError') {
            return res.status(401).json({ success: false, message: 'Token expired' });
        }
        return res.status(403).json({ success: false, message: 'Invalid token' });
    }
});

// ---- Auth: sign up ----
app.post('/sign-up', async (req, res) => {
    const { username, password } = req.body;
    if (!username || !password) {
        return res.status(400).json({ success: false, message: 'Username and password required' });
    }

    const hash = await bcrypt.hash(password, 10);
    try {
        db.prepare('INSERT INTO users (username, password) VALUES (?, ?)').run(username, hash);
        const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
        const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '7d' });
        res.json({ success: true, token, username });
    } catch (error) {
        console.log('Actual error: ' + error.message);
        res.status(409).json({ success: false, message: 'Username already taken' });
    }
});

// ---- Auth: sign in ----
app.post('/sign-in', async (req, res) => {
    const { username, password } = req.body;
    const user = db.prepare('SELECT * FROM users WHERE username = ?').get(username);
    if (!user) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const match = await bcrypt.compare(password, user.password);
    if (!match) return res.status(401).json({ success: false, message: 'Invalid credentials' });

    const token = jwt.sign({ userId: user.userId }, JWT_SECRET, { expiresIn: '7d' });
    res.json({ success: true, token, username });
});

// ---- Toilets: get all toilets ----
app.get('/get-toilets', (req, res) => {
    const toilets = db.prepare(`
        SELECT toilets.*, users.username AS userCreator
        FROM toilets
        JOIN users ON toilets.userId = users.userId
    `).all();

    // Convert isFree from integer (0/1) to boolean for the client
    const mapped = toilets.map(t => ({ ...t, isFree: !!t.isFree }));
    res.json({ success: true, toilets: mapped });
});

// ---- Toilets: get single toilet by ID ----
app.get('/get-toilet/:toiletId', (req, res) => {
    const toilet = db.prepare(`
        SELECT toilets.*, users.username AS userCreator
        FROM toilets
        JOIN users ON toilets.userId = users.userId
        WHERE toilets.toiletId = ?
    `).get(req.params.toiletId);

    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });

    // Convert isFree to boolean
    toilet.isFree = !!toilet.isFree;
    res.json({ success: true, toilet });
});

// ---- Toilets: create new toilet ----
app.post('/create-toilet', (req, res) => {
    const { toiletName, description, latitude, longitude, isFree } = req.body;
    const userId = getUserIdFromToken(req);

    if (!userId) return res.status(401).json({ success: false, message: 'Authentication required' });
    if (!toiletName) return res.status(400).json({ success: false, message: 'Toilet name is required' });
    if (!description) return res.status(400).json({ success: false, message: 'Description is required' });
    if (latitude == null) return res.status(400).json({ success: false, message: 'Latitude is required' });
    if (longitude == null) return res.status(400).json({ success: false, message: 'Longitude is required' });

    // Default isFree to true (1) if not provided
    const freeValue = isFree !== undefined ? (isFree ? 1 : 0) : 1;

    try {
        db.prepare(`
            INSERT INTO toilets (userId, toiletName, description, latitude, longitude, avgStar, isFree)
            VALUES (?, ?, ?, ?, ?, ?, ?)
        `).run(userId, toiletName, description, latitude, longitude, 0, freeValue);

        res.json({ success: true, message: 'Toilet created successfully' });
    } catch {
        res.status(409).json({ success: false, message: 'A toilet with that name already exists' });
    }
});

// ---- Toilets: delete toilet (owner only) ----
app.delete('/delete-toilet', (req, res) => {
    const { toiletId } = req.body;
    const userId = getUserIdFromToken(req);

    if (!userId) return res.status(401).json({ success: false, message: 'Authentication required' });

    const toilet = db.prepare('SELECT * FROM toilets WHERE toiletId = ?').get(toiletId);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });
    if (toilet.userId !== userId) {
        return res.status(403).json({ success: false, message: 'Not your toilet to delete' });
    }

    db.prepare('DELETE FROM toilets WHERE toiletId = ?').run(toiletId);
    res.json({ success: true, message: 'Toilet deleted' });
});

// ---- Reviews: create review ----
app.post('/create-review', (req, res) => {
    const { toiletId, star, title, description } = req.body;
    const userId = getUserIdFromToken(req);

    if (!userId) return res.status(401).json({ success: false, message: 'Authentication required' });
    if (!star) return res.status(400).json({ success: false, message: 'Rating required' });
    if (!title) return res.status(400).json({ success: false, message: 'Title required' });
    if (!description) return res.status(400).json({ success: false, message: 'Description required' });

    const toilet = db.prepare('SELECT * FROM toilets WHERE toiletId = ?').get(toiletId);
    if (!toilet) return res.status(404).json({ success: false, message: 'Toilet not found' });

    // Prevent duplicate reviews from the same user
    const existing = db.prepare(
        'SELECT * FROM reviews WHERE toiletId = ? AND userId = ?'
    ).get(toiletId, userId);
    if (existing) {
        return res.status(409).json({ success: false, message: 'You already reviewed this toilet' });
    }

    db.prepare(`
        INSERT INTO reviews (toiletId, userId, star, title, description)
        VALUES (?, ?, ?, ?, ?)
    `).run(toiletId, userId, star, title, description);

    // Recalculate average star rating for this toilet
    const { avgStar } = db.prepare(
        'SELECT ROUND(AVG(star), 1) as avgStar FROM reviews WHERE toiletId = ?'
    ).get(toiletId);
    db.prepare('UPDATE toilets SET avgStar = ? WHERE toiletId = ?').run(avgStar, toiletId);

    res.json({ success: true, message: 'Review created' });
});

// ---- Reviews: delete review (owner only) ----
app.delete('/delete-review', (req, res) => {
    const { reviewId } = req.body;
    const userId = getUserIdFromToken(req);

    if (!userId) return res.status(401).json({ success: false, message: 'Authentication required' });

    const review = db.prepare('SELECT * FROM reviews WHERE reviewId = ?').get(reviewId);
    if (!review) return res.status(404).json({ success: false, message: 'Review not found' });
    if (review.userId !== userId) {
        return res.status(403).json({ success: false, message: 'Not your review to delete' });
    }

    db.prepare('DELETE FROM reviews WHERE reviewId = ?').run(reviewId);

    // Recalculate average star rating after deletion
    const { toiletId } = review;
    const result = db.prepare(
        'SELECT ROUND(AVG(star), 1) as avgStar FROM reviews WHERE toiletId = ?'
    ).get(toiletId);
    const newAvg = result.avgStar ?? 0;
    db.prepare('UPDATE toilets SET avgStar = ? WHERE toiletId = ?').run(newAvg, toiletId);

    res.json({ success: true, message: 'Review deleted' });
});

// ---- Reviews: get reviews (optionally filtered by toiletId) ----
app.get('/get-reviews', (req, res) => {
    try {
        const { toiletId } = req.query;
        let reviews;

        if (toiletId) {
            // Get reviews for a specific toilet, including the reviewer's username
            reviews = db.prepare(`
                SELECT reviews.*, users.username AS userCreator
                FROM reviews
                JOIN users ON reviews.userId = users.userId
                WHERE reviews.toiletId = ?
                ORDER BY reviews.date DESC
            `).all(toiletId);
        } else {
            // Get all reviews with usernames
            reviews = db.prepare(`
                SELECT reviews.*, users.username AS userCreator
                FROM reviews
                JOIN users ON reviews.userId = users.userId
                ORDER BY reviews.date DESC
            `).all();
        }

        res.json({ success: true, reviews });
    } catch {
        res.json({ success: false, message: 'Failed to fetch reviews' });
    }
});

// ---- Users: get all users ----
app.get('/get-users', (req, res) => {
    try {
        const users = db.prepare('SELECT userId, username FROM users').all();
        res.json({ success: true, users });
    } catch {
        res.json({ success: false, message: 'No users found' });
    }
});

// ---- Start server ----
app.listen(3000, () => console.log('Server running on :3000'));

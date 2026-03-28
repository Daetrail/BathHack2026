const Database = require('better-sqlite3');
const db = new Database('app.db');

db.pragma('foreign_keys = ON');

db.exec(`
    CREATE TABLE IF NOT EXISTS users (
        userId INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS toilets (
        toiletId INTEGER PRIMARY KEY AUTOINCREMENT,
        userId INTEGER NOT NULL,
        toiletName TEXT UNIQUE NOT NULL,
        description TEXT NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        avgStar FLOAT NOT NULL,
        isFree INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY(userId) REFERENCES users(userId) ON DELETE CASCADE
    );

    CREATE TABLE IF NOT EXISTS reviews (
        reviewId INTEGER PRIMARY KEY AUTOINCREMENT,
        toiletId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        star INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date INTEGER DEFAULT (strftime('%s', 'now')),
        FOREIGN KEY(toiletId) REFERENCES toilets(toiletId) ON DELETE CASCADE,
        FOREIGN KEY(userId) REFERENCES users(userId) ON DELETE CASCADE
    );
`);

// Migration: add isFree column to existing databases that don't have it
try {
    db.exec('ALTER TABLE toilets ADD COLUMN isFree INTEGER NOT NULL DEFAULT 1');
    console.log('Migration: added isFree column to toilets');
} catch (e) {
    // Column already exists, no action needed
}

console.log('Tables:', db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all());

module.exports = db;

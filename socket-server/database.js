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
        toiletName TEXT UNIQUE NOT NULL,
        description TEXT NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        avgStar FLOAT NOT NULL
    );
    
    CREATE TABLE iF NOT EXISTS reviews (
        reviewId INTEGER PRIMARY KEY AUTOINCREMENT,
        toiletId INTEGER NOT NULL,
        userId INTEGER NOT NULL,
        star INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(toiletId) REFERENCES toilets(toiletId),
        FOREIGN KEY(userId) REFERENCES users(userId)
    );
`);

console.log('Tables:', db.prepare("SELECT name FROM sqlite_master WHERE type='table'").all());

module.exports = db;
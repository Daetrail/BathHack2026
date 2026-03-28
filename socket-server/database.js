const Database = require('better-sqlite3');
const db = new Database('app.db');

db.exec(`
    CREATE TABLE IF NOT EXISTS users (
        user_id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL
    );

    CREATE TABLE IF NOT EXISTS toilets (
        toilet_id INTEGER PRIMARY KEY AUTOINCREMENT,
        toilet_name TEXT UNIQUE NOT NULL,
        latitude TEXT NOT NULL,
        longitude TEXT NOT NULL,
        description TEXT NOT NULL
    );
    
    CREATE TABLE iF NOT EXISTS reviews (
        review_id INTEGER PRIMARY KEY AUTOINCREMENT,
        toilet_id INTEGER NOT NULL,
        user_id INTEGER NOT NULL,
        star INTEGER,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        date DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY(toilet_id) REFERENCES toilets(toilet_id),
        FOREIGN KEY(user_id) REFERENCES users(user_id)
    )
`);

module.exports = db;
-- Switch to the database
USE serpent_surge_db;

-- Create scores table
CREATE TABLE IF NOT EXISTS scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    score INT NOT NULL,
    difficulty INT NOT NULL
);

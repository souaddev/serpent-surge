-- -- Create database
-- CREATE DATABASE IF NOT EXISTS serpent_surge_db;

-- -- Create user and grant privileges
-- CREATE USER IF NOT EXISTS 'serpent_user'@'%' IDENTIFIED BY 'Topsecret@12';
-- GRANT ALL PRIVILEGES ON serpent_surge_db.* TO 'serpent_user'@'%';
-- FLUSH PRIVILEGES;

-- Switch to the database
USE serpent_surge_db;

-- Create scores table
CREATE TABLE IF NOT EXISTS scores (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name TEXT NOT NULL,
    score INT NOT NULL,
    difficulty INT NOT NULL
);
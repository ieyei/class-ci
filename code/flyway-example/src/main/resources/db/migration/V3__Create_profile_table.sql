CREATE TABLE IF NOT EXISTS user_profiles
(
    id      INT PRIMARY KEY,
    user_id INT,
    bio     VARCHAR(255),
    website VARCHAR(100),
    FOREIGN KEY (user_id) REFERENCES users (id)
);

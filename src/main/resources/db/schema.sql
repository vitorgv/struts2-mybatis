CREATE TABLE IF NOT EXISTS persons (
    id INTEGER AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    surname VARCHAR(100) NOT NULL,
    birth_date DATE NOT NULL,
    age INTEGER,
    insert_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    update_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO persons (name, surname, birth_date, age)
VALUES
    ('Ada', 'Lovelace', DATE '1815-12-10', 36),
    ('Alan', 'Turing', DATE '1912-06-23', 41);

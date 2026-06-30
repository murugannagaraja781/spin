CREATE DATABASE IF NOT EXISTS lucky_spin;
USE lucky_spin;

CREATE TABLE IF NOT EXISTS products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS salesmen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS spins (
    id INT AUTO_INCREMENT PRIMARY KEY,
    prize_name VARCHAR(255) NOT NULL,
    probability DECIMAL(5,2) DEFAULT 0.0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS customer_photos (
    id INT AUTO_INCREMENT PRIMARY KEY,
    file_path VARCHAR(500) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS winners (
    id INT AUTO_INCREMENT PRIMARY KEY,
    salesman_name VARCHAR(255),
    product_name VARCHAR(255),
    customer_name VARCHAR(255) NOT NULL,
    mobile_number VARCHAR(20) NOT NULL,
    prize_won VARCHAR(255) NOT NULL,
    photo_id INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (photo_id) REFERENCES customer_photos(id)
);

-- Insert dummy data
INSERT IGNORE INTO products (name, price) VALUES ('₹10 Product', 10.00), ('₹20 Product', 20.00);
INSERT IGNORE INTO salesmen (name) VALUES ('Ramesh Kumar'), ('Suresh Singh'), ('Rajesh Sharma'), ('Vikram Patel');

-- Create database
CREATE DATABASE momo_sms;
USE momo_sms;

-- 1. Users table (both sender & receiver)
CREATE TABLE Users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_number VARCHAR(20) UNIQUE NOT NULL,
    email VARCHAR(100)
);

-- 2. Transaction Categories (like payment, transfer, cash-in, cash-out)
CREATE TABLE Transaction_Categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    category_name VARCHAR(50) NOT NULL,
    description VARCHAR(255)
);

-- 3. Transactions (main table)
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    sender_id INT NOT NULL,
    receiver_id INT NOT NULL,
    category_id INT NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    transaction_date DATETIME NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',

    -- Foreign keys
    FOREIGN KEY (sender_id) REFERENCES Users(user_id),
    FOREIGN KEY (receiver_id) REFERENCES Users(user_id),
    FOREIGN KEY (category_id) REFERENCES Transaction_Categories(category_id)
);

-- 4. System Logs (track system activity)
CREATE TABLE System_Logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    transaction_id INT,
    log_message VARCHAR(255) NOT NULL,
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (transaction_id) REFERENCES Transactions(transaction_id)
);

-- Sample Data Insertions -----------------

-- Users
INSERT INTO Users (name, phone_number, email) VALUES
('Alice Mukamana', '+250788111111', 'alice@example.com'),
('Jean Claude', '+250788222222', 'jean@example.com'),
('Divine Uwase', '+250788333333', 'divine@example.com');

-- Categories
INSERT INTO Transaction_Categories (category_name, description) VALUES
('Payment', 'Paying for goods or services'),
('Transfer', 'Sending money to another user'),
('Cash-In', 'Depositing money into account'),
('Cash-Out', 'Withdrawing money from account');

-- Transactions
INSERT INTO Transactions (sender_id, receiver_id, category_id, amount, transaction_date, status) VALUES
(1, 2, 1, 1500.00, '2025-09-15 10:30:00', 'Completed'),
(2, 3, 2, 5000.00, '2025-09-15 11:00:00', 'Completed');

-- Logs
INSERT INTO System_Logs (transaction_id, log_message) VALUES
(1, 'Transaction processed successfully'),
(2, 'Transaction approved by system');


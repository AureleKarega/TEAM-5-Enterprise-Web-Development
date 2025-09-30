DROP DATABASE IF EXISTS momo_analytics;
CREATE DATABASE momo_analytics CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci;
USE momo_analytics;

CREATE TABLE users (
  user_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(200) NOT NULL COMMENT 'Full name of user',
  phone VARCHAR(32) NOT NULL COMMENT 'Phone number in E.164 format',
  email VARCHAR(200) DEFAULT NULL COMMENT 'Optional email',
  role ENUM('customer','driver','system','admin') NOT NULL DEFAULT 'customer' COMMENT 'User role',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY ux_users_phone (phone),
  UNIQUE KEY ux_users_email (email)
) ENGINE=InnoDB COMMENT='Application users (passengers, drivers, system accounts)';

CREATE TABLE transaction_categories (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  code VARCHAR(50) NOT NULL UNIQUE COMMENT 'Machine code (e.g., CASHIN)',
  name VARCHAR(100) NOT NULL COMMENT 'Human-friendly name',
  description VARCHAR(255) DEFAULT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB COMMENT='Transaction categories';

CREATE TABLE transactions (
  transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  timestamp DATETIME NOT NULL COMMENT 'When the transaction occurred (ISO)',
  amount DECIMAL(12,2) NOT NULL COMMENT 'Monetary amount',
  currency VARCHAR(8) NOT NULL DEFAULT 'RWF',
  text TEXT NULL COMMENT 'Raw SMS content',
  sender_user_id INT NULL COMMENT 'FK -> users (could be external if null)',
  receiver_user_id INT NULL COMMENT 'FK -> users (could be external if null)',
  category_id INT NOT NULL COMMENT 'FK -> transaction_categories',
  status ENUM('pending','completed','failed') NOT NULL DEFAULT 'completed',
  momo_reference VARCHAR(128) DEFAULT NULL COMMENT 'External MoMo transaction id',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_tx_sender FOREIGN KEY (sender_user_id) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_tx_receiver FOREIGN KEY (receiver_user_id) REFERENCES users(user_id) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT fk_tx_category FOREIGN KEY (category_id) REFERENCES transaction_categories(category_id) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Main transactions table';

CREATE TABLE transaction_tags (
  tag_id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL UNIQUE,
  description VARCHAR(255) DEFAULT NULL
) ENGINE=InnoDB COMMENT='Tags for transactions (reporting)';

CREATE TABLE transaction_tag_link (
  transaction_id BIGINT NOT NULL,
  tag_id INT NOT NULL,
  assigned_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (transaction_id, tag_id),
  CONSTRAINT fk_ttl_tx FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT fk_ttl_tag FOREIGN KEY (tag_id) REFERENCES transaction_tags(tag_id) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB COMMENT='Junction table between transactions and tags';

CREATE TABLE system_logs (
  log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  level ENUM('DEBUG','INFO','WARN','ERROR') NOT NULL DEFAULT 'INFO',
  component VARCHAR(100) NOT NULL COMMENT 'ETL component name',
  message TEXT NOT NULL,
  meta JSON NULL
) ENGINE=InnoDB COMMENT='ETL and system logs';

CREATE INDEX idx_tx_timestamp ON transactions(timestamp);
CREATE INDEX idx_tx_sender ON transactions(sender_user_id);
CREATE INDEX idx_tx_receiver ON transactions(receiver_user_id);
CREATE INDEX idx_tx_category ON transactions(category_id);

ALTER TABLE transactions ADD CONSTRAINT chk_amount_nonneg CHECK (amount >= 0);
ALTER TABLE users ADD CONSTRAINT chk_phone_nonempty CHECK (LENGTH(phone) > 5);


INSERT INTO users (name, phone, email, role) VALUES
('Alice Mukamana', '+250788123456', 'alice@example.com','customer'),
('Jean Claude', '+250788654321', 'jean@example.com','driver'),
('Finance System', '+0000000000', NULL,'system'),
('Bob Uwimana', '+250788999000','bob@example.com','customer'),
('Celine N', '+250788777111','celine@example.com','customer');

INSERT INTO transaction_categories (code, name, description) VALUES
('CASHIN','Cash In','Incoming transfers or deposits'),
('CASHOUT','Cash Out','Withdrawals from account'),
('AIRTIME','Airtime','Airtime topups purchased'),
('MERCHANT','MerchantPayment','Payments to merchants'),
('FEE','Fee','System fees or charges');


INSERT INTO transactions (timestamp, amount, currency, text, sender_user_id, receiver_user_id, category_id, status, momo_reference) VALUES
('2025-09-10 08:29:00', 1500.00, 'RWF', 'Payment to Jean for ride', 1, 2, (SELECT category_id FROM transaction_categories WHERE code='MERCHANT'), 'completed', 'MOMO123456789'),
('2025-09-11 10:00:00', 5000.00, 'RWF', 'Salary deposit', NULL, 1, (SELECT category_id FROM transaction_categories WHERE code='CASHIN'), 'completed', 'MOMO22334455'),
('2025-09-12 09:30:00', 200.00, 'RWF', 'Airtime purchase', 1, NULL, (SELECT category_id FROM transaction_categories WHERE code='AIRTIME'), 'completed', 'MOMO99887766'),
('2025-09-12 15:00:00', 1000.00, 'RWF', 'Cash out at agent', 1, NULL, (SELECT category_id FROM transaction_categories WHERE code='CASHOUT'), 'completed', 'MOMO88776655'),
('2025-09-13 18:45:00', 300.00, 'RWF', 'Fee charge', NULL, 1, (SELECT category_id FROM transaction_categories WHERE code='FEE'), 'completed', 'MOMO55667788');


INSERT INTO transaction_tags (name, description) VALUES
('ride','Moto-taxi ride payments'),
('salary','Salary/Payroll'),
('topup','Airtime topup'),
('cashout','Withdrawal'),
('fee','System fee');


INSERT INTO transaction_tag_link (transaction_id, tag_id) VALUES
(1, (SELECT tag_id FROM transaction_tags WHERE name='ride')),
(2, (SELECT tag_id FROM transaction_tags WHERE name='salary')),
(3, (SELECT tag_id FROM transaction_tags WHERE name='topup')),
(4, (SELECT tag_id FROM transaction_tags WHERE name='cashout')),
(5, (SELECT tag_id FROM transaction_tags WHERE name='fee'));


INSERT INTO system_logs (level, component, message, meta) VALUES
('INFO','etl.run','ETL started', JSON_OBJECT('pid',1234)),
('INFO','parse_xml','Found 5 messages', NULL),
('WARN','clean_normalize','1 message missing date', JSON_OBJECT('count',1)),
('ERROR','load_db','Failed to insert row', JSON_OBJECT('tx_id','tmp-42')),
('INFO','etl.run','ETL finished', NULL);


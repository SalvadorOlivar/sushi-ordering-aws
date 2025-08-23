# Create database 'sushi' if it does not exist
mysql --defaults-file=~/.my.cnf -e "CREATE DATABASE IF NOT EXISTS sushi;"

# Create tables in the 'sushi' database
mysql --defaults-file=~/.my.cnf sushi <<SQL
CREATE TABLE IF NOT EXISTS menu (
	id INT AUTO_INCREMENT PRIMARY KEY,
	dish_name VARCHAR(100) NOT NULL,
	price DECIMAL(10,2) NOT NULL,
	description VARCHAR(255),
	available BOOLEAN DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS users (
	id INT AUTO_INCREMENT PRIMARY KEY,
	username VARCHAR(50) NOT NULL UNIQUE,
	email VARCHAR(100) NOT NULL UNIQUE,
	full_name VARCHAR(100),
	phone VARCHAR(30),
	address VARCHAR(255),
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
	user_id INT NOT NULL,
	total DECIMAL(10,2) NOT NULL,
	created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	FOREIGN KEY (user_id) REFERENCES users(id)
);

CREATE TABLE IF NOT EXISTS order_items (
	id BIGINT AUTO_INCREMENT PRIMARY KEY,
	order_id BIGINT NOT NULL,
	menu_id INT NOT NULL,
	quantity INT NOT NULL DEFAULT 1,
	FOREIGN KEY (order_id) REFERENCES orders(id),
	FOREIGN KEY (menu_id) REFERENCES menu(id)
);
SQL

# Insert 5 random menu items
mysql --defaults-file=~/.my.cnf sushi -e "INSERT INTO menu (dish_name, price, description, available) VALUES
	('Dragon Roll', 12.99, 'Shrimp tempura, avocado, eel sauce', TRUE),
	('Spicy Tuna Roll', 9.50, 'Tuna, spicy mayo, cucumber', TRUE),
	('Salmon Nigiri', 7.00, 'Fresh salmon over rice', TRUE),
	('Veggie Roll', 8.25, 'Cucumber, avocado, carrot, seaweed', TRUE),
	('Rainbow Roll', 13.75, 'Crab, avocado, assorted fish on top', TRUE);"

# Insert 1 test user
mysql --defaults-file=~/.my.cnf sushi -e "INSERT INTO users (username, email, full_name, phone, address) VALUES
	('salvaolivar', 'salvaolivar@example.com', 'Salvador Olivar', '+1234567890', 'Av Brasil 2420');"
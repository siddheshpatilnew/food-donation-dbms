DROP DATABASE IF EXISTS food_donation;
CREATE DATABASE food_donation;
USE food_donation;

CREATE TABLE Donor (
    donor_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(200),
    donor_category VARCHAR(50)
);

CREATE TABLE NGO (
    ngo_id INT PRIMARY KEY AUTO_INCREMENT,
    ngo_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(200)
);

CREATE TABLE Beneficiary (
    beneficiary_id INT PRIMARY KEY AUTO_INCREMENT,
    beneficiary_name VARCHAR(100) NOT NULL,
    phone VARCHAR(15),
    address VARCHAR(200),
    people_count INT
);

CREATE TABLE Food (
    food_id INT PRIMARY KEY AUTO_INCREMENT,
    donor_id INT,
    food_name VARCHAR(100) NOT NULL,
    quantity INT CHECK (quantity >= 0),
    food_type VARCHAR(50),
    expiry_date DATE,
    status VARCHAR(30) DEFAULT 'Available',
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE Delivery (
    delivery_id INT PRIMARY KEY AUTO_INCREMENT,
    food_id INT,
    ngo_id INT,
    beneficiary_id INT,
    delivery_date DATE,
    quantity INT CHECK (quantity > 0),
    delivery_status VARCHAR(30) DEFAULT 'In Transit',
    FOREIGN KEY (food_id) REFERENCES Food(food_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (ngo_id) REFERENCES NGO(ngo_id)
        ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY (beneficiary_id) REFERENCES Beneficiary(beneficiary_id)
        ON DELETE CASCADE ON UPDATE CASCADE
);
USE food_donation;

INSERT INTO Donor (donor_name, phone, email, address, donor_category) VALUES
('Taj Hotel', '9876543210', 'taj@gmail.com', 'Mumbai', 'Hotel'),
('Food Corner Restaurant', '9876543211', 'foodcorner@gmail.com', 'Pune', 'Restaurant'),
('Aditya Household', '9876543212', 'aditya@gmail.com', 'Pune', 'Household'),
('Grand Restaurant', '9876543213', 'grand@gmail.com', 'Mumbai', 'Restaurant');

INSERT INTO NGO (ngo_name, phone, email, address) VALUES
('Helping Hands NGO', '9000000001', 'helpinghands@gmail.com', 'Pune'),
('Food For All', '9000000002', 'foodforall@gmail.com', 'Mumbai'),
('Care Foundation', '9000000003', 'care@gmail.com', 'Nashik');

INSERT INTO Beneficiary (beneficiary_name, phone, address, people_count) VALUES
('Hope Shelter', '8000000001', 'Pune', 50),
('Children Care Home', '8000000002', 'Mumbai', 35),
('Old Age Home', '8000000003', 'Nashik', 40);

INSERT INTO Food (donor_id, food_name, quantity, food_type, expiry_date, status) VALUES
(1, 'Rice and Dal', 100, 'Cooked Food', '2026-11-24', 'Available'),
(2, 'Vegetable Biryani', 80, 'Cooked Food', '2026-11-23', 'Available'),
(3, 'Chapati and Sabzi', 50, 'Cooked Food', '2026-11-23', 'Available'),
(4, 'Bread and Sandwiches', 60, 'Bakery', '2026-11-25', 'Available');
USE food_donation;

DROP TRIGGER IF EXISTS after_delivery_insert;
DROP PROCEDURE IF EXISTS AddDelivery;

DELIMITER //

CREATE TRIGGER after_delivery_insert
AFTER INSERT ON Delivery
FOR EACH ROW
BEGIN
    UPDATE Food
    SET quantity = quantity - NEW.quantity,
        status = IF(quantity = 0, 'Delivered', status)
    WHERE food_id = NEW.food_id;
END//

CREATE PROCEDURE AddDelivery(
    IN p_food_id INT,
    IN p_ngo_id INT,
    IN p_beneficiary_id INT,
    IN p_qty INT
)
BEGIN
    DECLARE stock INT;

    SELECT quantity INTO stock FROM Food WHERE food_id = p_food_id;

    IF stock IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Food item not found';
    ELSEIF p_qty > stock THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Not enough stock available';
    ELSE
        INSERT INTO Delivery (food_id, ngo_id, beneficiary_id, delivery_date, quantity, delivery_status)
        VALUES (p_food_id, p_ngo_id, p_beneficiary_id, CURDATE(), p_qty, 'In Transit');
    END IF;
END//

DELIMITER ;
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'normal_user'@'localhost';

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@123';
CREATE USER 'normal_user'@'localhost' IDENTIFIED BY 'Normal@123';

GRANT ALL PRIVILEGES ON food_donation.* TO 'admin_user'@'localhost';

GRANT SELECT ON food_donation.* TO 'normal_user'@'localhost';
GRANT INSERT ON food_donation.Food TO 'normal_user'@'localhost';
GRANT EXECUTE ON PROCEDURE food_donation.AddDelivery TO 'normal_user'@'localhost';

FLUSH PRIVILEGES;

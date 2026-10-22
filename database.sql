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

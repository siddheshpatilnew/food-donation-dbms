DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'normal_user'@'localhost';

CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@123';
CREATE USER 'normal_user'@'localhost' IDENTIFIED BY 'Normal@123';

GRANT ALL PRIVILEGES ON food_donation.* TO 'admin_user'@'localhost';

GRANT SELECT ON food_donation.* TO 'normal_user'@'localhost';
GRANT INSERT ON food_donation.Food TO 'normal_user'@'localhost';
GRANT EXECUTE ON PROCEDURE food_donation.AddDelivery TO 'normal_user'@'localhost';

FLUSH PRIVILEGES;

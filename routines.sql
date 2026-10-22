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

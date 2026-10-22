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

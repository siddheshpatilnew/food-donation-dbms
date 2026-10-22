# Food Donation Management System (DBMS Mini Project)

A web application that connects food donors (hotels, restaurants, households) with NGOs and beneficiaries
(shelters, care homes), so surplus food is delivered instead of wasted.

**Backend:** MySQL  |  **Frontend:** Python (Flask) + HTML/CSS

## Features

* 5 tables: Donor, Food, NGO, Beneficiary, Delivery (3NF, with cascading foreign keys)
* Insert, update, delete and search of food items
* Delivery module that calls a stored procedure (`AddDelivery`) and a trigger that reduces food stock automatically
* Two user types (Admin and Normal) with privileges granted using DCL (GRANT)
* Front-end validation (required fields, quantity >= 1, expiry date not in the past)

## Files

|File|Purpose|
|-|-|
|`database.sql`|DDL: creates database, tables, primary and foreign keys|
|`data.sql`|DML: sample data|
|`routines.sql`|Trigger `after\_delivery\_insert` and procedure `AddDelivery`|
|`dcl.sql`|Creates `admin\_user` and `normal\_user` and grants privileges|
|`all\_in\_one.sql`|All four scripts combined (run this one)|
|`app.py`, `config.py`, `templates/`|Flask web application|

## How to run

1. Install Python 3, MySQL Server and MySQL Workbench.
2. Install libraries: `pip install flask mysql-connector-python`
3. In MySQL Workbench, open `all\_in\_one.sql` and run it (lightning bolt button).
4. In a terminal, inside this folder: `python app.py`
5. Open http://127.0.0.1:5001

## Logins

|Role|Website login|MySQL account used|
|-|-|-|
|Admin|`admin` / `admin123`|`admin\_user` (all privileges)|
|Normal user|`user` / `user123`|`normal\_user` (SELECT, add food, create delivery only)|

The passwords above are demo passwords for this project's local database users only.

## Group members

* Siddhesh Patil
* Vinit Patil


-- 1.1
CREATE TABLE employees (employee_id SERIAL PRIMARY KEY, first_name TEXT, last_name TEXT, age INT CHECK (age between 18 AND 65), salary NUMERIC CHECK (salary > 0));
-- 1.2
CREATE TABLE products_catalog (product_id SERIAL PRIMARY KEY, product_name TEXT, regular_price NUMERIC, discount_price NUMERIC, CONSTRAINT valid_discount CHECK (regular_price > 0 AND discount_price BETWEEN 0 AND regular_price));
CREATE TABLE
-- 1.3
CREATE TABLE bookings (booking_id SERIAL PRIMARY KEY, check_in_date DATE, check_out_date DATE CHECK (check_out_date > check_in_date), num_guests INT CHECK (num_guests BETWEEN 1 AND 10));
-- 1.4

-- Valid data - employees
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('John', 'Gaster', 25, 300000), ('Anna', 'Gaster', 40, 450000), ('Bob', 'Gaster', 41, 450001), ('Tren', 'Gaster', 42, 660000), ('Stan', 'Gaster', 43, 6600);

-- Invalid: age below 18
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Pit', 'Nit', 16, 200000);
-- Violates age CHECK (age BETWEEN 18 AND 65)

-- Invalid: age above 65
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Gaster', 'Green', 70, 250000);
-- Violates age CHECK (age BETWEEN 18 AND 65)

-- Invalid: salary is zero
INSERT INTO employees (first_name, last_name, age, salary)
VALUES ('Susie', 'Gaster', 30, 0);
-- Violates salary CHECK (salary > 0)


-- Valid data - products_catalog
INSERT INTO products_catalog
(product_name, regular_price, discount_price)
VALUES ('Laptop', 500000, 450000), ('Mouse', 10000, 8000), ('Ware', 10001, 8001), ('Meleer', 10002, 8002), ('Pwarte', 66000, 1);

-- Invalid: regular price is zero
INSERT INTO products_catalog
(product_name, regular_price, discount_price)
VALUES ('Keyboard', 0, 0);
-- Violates valid_discount: regular_price must be > 0

-- Invalid: discount price is negative
INSERT INTO products_catalog
(product_name, regular_price, discount_price)
VALUES ('Monitor', 100000, -5000);
-- Violates valid_discount: discount_price must be >= 0

-- Invalid: discount price exceeds regular price
INSERT INTO products_catalog
(product_name, regular_price, discount_price)
VALUES ('Phone', 200000, 250000);
-- Violates valid_discount: discount_price must be <= regular_price


-- Valid data - bookings
INSERT INTO bookings
(check_in_date, check_out_date, num_guests)
VALUES ('2026-11-10', '2026-11-15', 2), ('2026-12-01', '2026-12-05', 5), ('2026-12-02', '2026-12-06', 9), ('2026-12-01', '2026-12-07', 6), ('2026-12-04', '2026-12-12', 6);

-- Invalid: check-out date is before check-in date
INSERT INTO bookings
(check_in_date, check_out_date, num_guests)
VALUES ('2026-11-15', '2026-11-10', 2);
-- Violates CHECK (check_out_date > check_in_date)

-- Invalid: same check-in and check-out dates
INSERT INTO bookings
(check_in_date, check_out_date, num_guests)
VALUES ('2026-11-10', '2026-11-10', 2);
-- Violates CHECK (check_out_date > check_in_date)

-- Invalid: zero guests
INSERT INTO bookings
(check_in_date, check_out_date, num_guests)
VALUES ('2026-11-10', '2026-11-15', 0);
-- Violates CHECK (num_guests BETWEEN 1 AND 10)

-- Invalid: more than 10 guests
INSERT INTO bookings
(check_in_date, check_out_date, num_guests)
VALUES ('2026-11-10', '2026-11-15', 12);
-- Violates CHECK (num_guests BETWEEN 1 AND 10)


-- 2.1
CREATE TABLE customers (customer_id SERIAL PRIMARY KEY, email TEXT CHECK (email IS NOT NULL), phone TEXT, registration_date DATE CHECK (registration_date IS NOT NULL));
-- 2.2
CREATE TABLE inventory (item_id SERIAL PRIMARY KEY, item_name TEXT NOT NULL, quantity INT NOT NULL CHECK (quantity >= 0), unit_price NUMERIC NOT NULL CHECK (unit_price > 0), last_updated TIMESTAMP NOT NULL);
-- 2.3

-- 1. Valid data - customers
INSERT INTO customers (email, phone, registration_date)
VALUES ('nhjo@gmosi.com', '87001234567', '2026-10-10'), ('gasuey@gmall.com', '87001234568', '2026-10-5'), ('kwiw@gmail.com', '87001234560', '2026-10-7'), ('aosiwj@gmail.com', '87001234566', '2026-10-2'), ('ksjwi@gmail.com', '87001234562', '2026-10-1');

-- 2. Invalid: NULL in a NOT NULL column
INSERT INTO customers (email, phone, registration_date)
VALUES (NULL, '87001234567', '2026-10-13');
-- Violates NOT NULL on email

-- 3. NULL in a nullable column
INSERT INTO customers (email, phone, registration_date)
VALUES ('anna@example.com', NULL, '2026-10-13');
-- Succeeds because phone may be null


-- 1. Valid data - inventory
INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES ('Laptop', 10, 450000, CURRENT_TIMESTAMP), ('Loptap', 11, 450001, CURRENT_TIMESTAMP), ('Spetre', 20, 456300, CURRENT_TIMESTAMP), ('Qwoiterne', 40, 200, CURRENT_TIMESTAMP), ('Drent', 1, 10000000000, CURRENT_TIMESTAMP);

-- 2. Invalid: NULL in a NOT NULL column
INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES (NULL, 10, 450000, CURRENT_TIMESTAMP);
-- Violates NOT NULL on item_name

-- 3. NULL in a nullable column
INSERT INTO inventory (item_name, quantity, unit_price, last_updated)
VALUES ('Mouse', 20, 5000, NULL);
-- Fails because last_updated is NOT NULL

-- 3.1
CREATE TABLE users (user_id SERIAL PRIMARY KEY, username TEXT UNIQUE, email TEXT UNIQUE, created_at TIMESTAMP);
-- 3.2
CREATE TABLE course_enrollments (enrollment_id SERIAL PRIMARY KEY, student_id INT, course_code TEXT, semester TEXT);
ALTER TABLE course_enrollments ADD CONSTRAINT p UNIQUE (student_id, course_code, semester);
-- 3.3
ALTER TABLE users ADD CONSTRAINT unique_username UNIQUE (username);
ALTER TABLE users ADD CONSTRAINT unique_email UNIQUE (email);

-- Valid data - users
INSERT INTO users (username, email, created_at) VALUES ('gaster', 'dounle_d66@gmail.com', NULL), ('m', 'w66@gmail.com', NULL), ('goner', 'dounle_dd66@gmail.com', NULL), ('green gaster', 'dd66@gmail.com', NULL), ('eggman', 'dounle_dd6@gmail.com', NULL);
-- Invalid
INSERT INTO users (username, email, created_at) VALUES ('not_gaster', 'dounle_d66@gmail.com', NULL);
-- The error on email

-- Invalid - course_enrollments
INSERT INTO course_enrollments (student_id, course_code, semester) VALUES (1, 'dpi', '2'), (1, 'dpi', '3'), (1, 'ksi', '2'), (1, 'ksi', 1), (2, 'dpi', '2');
INSERT INTO course_enrollments (student_id, course_code, semester) VALUES (1, 'dpi', '3');
-- The error on duplicate of second row

-- 4.1
CREATE TABLE departments (dept_id SERIAL PRIMARY KEY, dept_name TEXT NOT NULL, location TEXT);
-- Valid data
INSERT INTO departments (dept_name, location) VALUES ('Pinecones', 'Some1'), ('Pineapples', 'Some2'), ('Greeks', 'Somee2');
-- Invalid
INSERT INTO departments (dept_id, dept_name, location) VALUES (1, 'templated', 'somet');
-- Error on duplicate
INSERT INTO departments (dept_id, dept_name, location) VALUES (NULL, 'templatedd', 'someet');
-- PRIMARY KEY does not let NULL values

-- 4.2
CREATE TABLE student_courses (student_id INT, course_id INT, enrollment_date DATE, grade TEXT, PRIMARY KEY (student_id, course_id));
-- 4.3
/* 1) UNIQUE adds any row that is unique, PRIMARY KEY define any row as unique. So the difference mainly that UNIQUE may not add some rows
   2) Single column PK needed for 1:1 or 1:N relationships, Multicolumn PK - for M:N one. Also multicolumn PK is needed if single column PK does not provide enough uniqueness (in some database designs).
   3) Because UNIQUE constraint works as condition to insert a row, while PK only works as set of primary keys because multiple primary keys already work as a set. So it means PK is enclosed by set, while UNIQUE can select rows at several conditions. */

-- 5.1 
CREATE TABLE employees_dept (emp_id SERIAL PRIMARY KEY, emp_name TEXT NOT NULL, dept_id INT REFERENCES departments(dept_id), hire_date DATE);

-- Valid data
INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES ('Den', 1, NULL), ('Tren', 1, NULL), ('Swen', 2, NULL), ('Yen', 1, NULL), ('Robert', 2, NULL);
-- Invalid
INSERT INTO employees_dept (emp_name, dept_id, hire_date) VALUES ('Gaster', 66, CURRENT_DATE);
-- Error on non-existent dept_id 66

-- 5.2
CREATE TABLE authors (author_id SERIAL PRIMARY KEY, author_name TEXT NOT NULL, country TEXT);
CREATE TABLE publishers (publisher_id SERIAL PRIMARY KEY, publisher_name TEXT NOT NULL, city TEXT);
CREATE TABLE books (book_id SERIAL PRIMARY KEY, title TEXT NOT NULL, author_id INT REFERENCES authors(author_id), publisher_id INT REFERENCES publishers(publisher_id), publication_year INT, isbn TEXT UNIQUE);

-- Sample data - authors
INSERT INTO authors (author_name, country) VALUES ('Robert', 'USA'), ('Plonby', 'Switzerland'), ('Crotzky', 'Poland'), ('Nidren', 'Belgium'), ('Jehxir', 'Slovakia');
-- Sample data - publishers
INSERT INTO publishers (publisher_name, city) VALUES ('Plin', 'Amsterdam'), ('Green', 'Hometown'), ('Swin', 'Trivinia'), ('Plotnyi', 'Berlin'), ('Jerry', 'Moscow');
-- Sample data - books
INSERT INTO books (title, author_id, publisher_id, publication_year, isbn) VALUES ('Mystery Man', 1, 4, 1966, '667-287-27-4994-1'), ('How to be a big shot', 2, 4, 1997, '928-468-47-1997-0'), ('How to draw dragons', 5, 2, 2001, '210-273-73-2973-5'), ('Kamen', 5, 3, 2000, '291-387-10-2763-9'), ('Trenie', 5, 1, 1999, '208-292-27-4994-1');

-- 5.3
CREATE TABLE categories (category_id INTEGER PRIMARY KEY, category_name TEXT NOT NULL);

CREATE TABLE products_fk (product_id INTEGER PRIMARY KEY, product_name TEXT NOT NULL, category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT);

CREATE TABLE orders (order_id INTEGER PRIMARY KEY, order_date DATE NOT NULL);

CREATE TABLE order_items (item_id INTEGER PRIMARY KEY, order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE, product_id INTEGER REFERENCES products_fk(product_id), quantity INTEGER CHECK (quantity > 0));
-- Sample data
INSERT INTO categories VALUES (1, 'Food'), (2, 'Clothing'), (3, 'Books'), (4, 'Furniture'), (5, 'Sports');

INSERT INTO products_fk VALUES (1, 'Laptop', 1), (2, 'T-Shirt', 2), (3, 'Novel', 3), (4, 'Chair', 4), (5, 'Football', 5);

INSERT INTO orders VALUES (1, '2026-10-01'), (2, '2026-10-02'), (3, '2026-10-03'), (4, '2026-10-04'), (5, '2026-10-05');

INSERT INTO order_items VALUES (1, 1, 1, 1), (2, 1, 3, 2), (3, 2, 2, 3), (4, 3, 4, 1), (5, 5, 5, 2);

-- 1)
DELETE FROM categories WHERE category_id IN (SELECT category_id FROM products_fk);
-- Failed with restrict, error was raised

-- 2)
DELETE FROM orders WHERE order_id = 1;
SELECT 1 FROM order_items WHERE order_id = 1;
-- None result, so the order was deleted

-- 6.1
CREATE TABLE customers (customer_id SERIAL PRIMARY KEY, name TEXT NOT NULL, email TEXT UNIQUE, phone TEXT, registration_date DATE);

CREATE TABLE products (product_id SERIAL PRIMARY KEY, name TEXT NOT NULL, description TEXT, price NUMERIC(10,2) NOT NULL CHECK (price > 0), stock_quantity INTEGER NOT NULL);

CREATE TABLE orders (order_id SERIAL PRIMARY KEY, customer_id INTEGER REFERENCES customers(customer_id) ON DELETE CASCADE, order_date DATE NOT NULL, total_amount NUMERIC(10,2) NOT NULL, status TEXT CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled')));

CREATE TABLE order_details (order_detail_id SERIAL PRIMARY KEY, order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE, product_id INTEGER REFERENCES products(product_id), quantity INTEGER NOT NULL CHECK (quantity >= 0), unit_price NUMERIC(10,2) NOT NULL);

-- Sample data
INSERT INTO customers (name, email, phone, registration_date) VALUES
('Susie Gaster', 'sus@fmkdd.com', '+77011234567', '2026-01-10'),
('Noelle Gaster', 'yellow@gmail.com', '+77021234567', '2026-02-15'),
('Gaster Gaster', 'gus@gmail.com', '+77051234567', '2026-03-20'),
('Double D', 'dd@gmail.com', '+77071234567', '2026-04-05'),
('Bob', 'bob@gmail.com', '+77081234567', '2026-05-12');

INSERT INTO products (name, description, price, stock_quantity) VALUES
('Laptop', '15-inch laptop', 450000.00, 10),
('Mouse', 'Wireless mouse', 7500.00, 50),
('Keyboard', 'Mechanical keyboard', 25000.00, 30),
('Monitor', '27-inch monitor', 120000.00, 15),
('Headphones', 'Wireless headphones', 18000.00, 40);

INSERT INTO orders (customer_id, order_date, total_amount, status) VALUES
(1, '2026-06-01', 457500.00, 'pending'),
(2, '2026-06-03', 25000.00, 'processing'),
(3, '2026-06-05', 120000.00, 'shipped'),
(4, '2026-06-07', 18000.00, 'delivered'),
(5, '2026-06-10', 32500.00, 'cancelled');

INSERT INTO order_details (order_id, product_id, quantity, unit_price) VALUES
(1, 1, 1, 450000.00),
(1, 2, 1, 7500.00),
(2, 3, 1, 25000.00),
(3, 4, 1, 120000.00),
(4, 5, 1, 18000.00);
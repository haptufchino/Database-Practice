-- Create table: employees
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(50),
 dept_id INT,
 salary DECIMAL(10, 2)
);
-- Create table: departments
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
-- Create table: projects
CREATE TABLE projects (
 project_id INT PRIMARY KEY,
 project_name VARCHAR(50),
 dept_id INT,
 budget DECIMAL(10, 2)
);

-- Insert data into employees
INSERT INTO employees (emp_id, emp_name, dept_id, salary) 
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
-- Insert data into departments
INSERT INTO departments (dept_id, dept_name, location) VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Finance', 'Building C'),
(104, 'Marketing', 'Building D');
-- Insert data into projects
INSERT INTO projects (project_id, project_name, dept_id, 
budget) VALUES
(1, 'Website Redesign', 101, 100000),
(2, 'Employee Training', 102, 50000),
(3, 'Budget Analysis', 103, 75000),
(4, 'Cloud Migration', 101, 150000),
(5, 'AI Research', NULL, 200000);

-- Task 2.1
-- Your query here
SELECT e.emp_name, d.dept_name
FROM employees e CROSS JOIN departments d;
-- The result table has 4 × 5 rows => 20

-- Task 2.2
SELECT e.emp_name, d.dept_name FROM employees e, departments d;
SELECT e.emp_name, d.dept_name FROM employees e INNER JOIN departments d ON TRUE;

-- Task 2.3
SELECT e.emp_name, p.project_name FROM employees e CROSS JOIN projects p;

-- Task 3.1
-- Your query here
SELECT e.emp_name, d.dept_name, d.location
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id;
-- 4; Tom Brown has NULL value in dept_id, which isn't in departments table, so there is no match

-- Task 3.2
-- Your query here
SELECT emp_name, dept_name, location
FROM employees
INNER JOIN departments USING (dept_id);
-- There is no difference, it does the same work

-- Task 3.3
-- Your query here
SELECT emp_name, dept_name, location
FROM employees
NATURAL INNER JOIN departments;
-- employees -= (dept_id) = (dept_id) =- departments

-- Task 3.4
-- Your query here
SELECT e.emp_name, d.dept_name, p.project_name
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
INNER JOIN projects p ON d.dept_id = p.dept_id;

-- Task 4.1
-- Your query here
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS 
dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id;
-- Tom Brown is displayed with NULL values as default in emp_dept, dept_dept and dept_name

-- Task 4.2
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS 
dept_dept, d.dept_name
FROM employees e
LEFT JOIN departments d USING (dept_id);

-- Task 4.3
-- Your query here
SELECT e.emp_name, e.dept_id
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.dept_id IS NULL;

-- Task 4.4
-- Your query here
SELECT d.dept_name, COUNT(e.emp_id) AS employee_count
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
ORDER BY employee_count DESC;

-- Task 5.1
-- Your query here
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id;

-- Task 5.2
SELECT e.emp_name, d.dept_namd FROM departments d LEFT JOIN employees e ON d.dept_id = e.dept_id

-- Task 5.3
SELECT e.emp_name, d.dept_name
FROM employees e
RIGHT JOIN departments d ON e.dept_id = d.dept_id WHERE e.emp_id is NULL;

-- Task 6.1
-- Your query here
SELECT e.emp_name, e.dept_id AS emp_dept, d.dept_id AS 
dept_dept, d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id;
-- On the left side the record with emp_id = 5, on the right side - none

-- Task 6.2
-- Your query here
SELECT d.dept_name, p.project_name, p.budget
FROM departments d
FULL JOIN projects p ON d.dept_id = p.dept_id;

-- Task 6.3
-- Your query here
SELECT 
 CASE 
 WHEN e.emp_id IS NULL THEN 'Department without 
employees'
 WHEN d.dept_id IS NULL THEN 'Employee without 
department'
 ELSE 'Matched'
 END AS record_status,
 e.emp_name,
 d.dept_name
FROM employees e
FULL JOIN departments d ON e.dept_id = d.dept_id
WHERE e.emp_id IS NULL OR d.dept_id IS NULL;
-- The WHERE condition filters rows on eitheir condition, then CASE statement distinguishes them into 2 categories

-- Task 7.1
-- Query 1: Filter in ON clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id AND 
d.location = 'Building A';

-- Task 7.2
-- Query 2: Filter in WHERE clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
LEFT JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- The results are different. ON clause leaves employees who has no match because it is left join, so it leaves unfiltered rows with NULL values on the right side. While WHERE clause nihilates rows that failed on condition. So generally WHERE clause filters with deleting unfiltered rows.

-- Task 7.3
-- Query 1: Filter in ON clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id AND 
d.location = 'Building A';

-- Query 2: Filter in WHERE clause
SELECT e.emp_name, d.dept_name, e.salary
FROM employees e
INNER JOIN departments d ON e.dept_id = d.dept_id
WHERE d.location = 'Building A';
-- There is no difference because both clauses nihilates unmatched rows

-- Task 8.1
-- Your query here
SELECT 
 d.dept_name,
 e.emp_name,
 e.salary,
 p.project_name,
 p.budget
FROM departments d
LEFT JOIN employees e ON d.dept_id = e.dept_id
LEFT JOIN projects p ON d.dept_id = p.dept_id
ORDER BY d.dept_name, e.emp_name;

-- Task 8.2

-- Add manager_id column
ALTER TABLE employees ADD COLUMN manager_id INT;

-- Update with sample data
UPDATE employees SET manager_id = 3 WHERE emp_id = 1;
UPDATE employees SET manager_id = 3 WHERE emp_id = 2;
UPDATE employees SET manager_id = NULL WHERE emp_id = 3;
UPDATE employees SET manager_id = 3 WHERE emp_id = 4;
UPDATE employees SET manager_id = 3 WHERE emp_id = 5;

-- Self join query
SELECT 
 e.emp_name AS employee,
 m.emp_name AS manager
FROM employees e
LEFT JOIN employees m ON e.manager_id = m.emp_id;

-- Task 8.3
-- Your query here
SELECT d.dept_name, AVG(e.salary) AS avg_salary
FROM departments d
INNER JOIN employees e ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name
HAVING AVG(e.salary) > 50000;

-- 1
-- INNER JOIN returns intersection between two tables, LEFT JOIN returns all content from first table and the intersection

-- 2
-- CROSS JOIN is needed for displaying all possible combinations of rows of 2 table, like for applying some schedule for all employees and etc.

-- 3
-- because OUTER JOIN remain unfiltered rows, and thus WHERE clause clean up more content than ON one. And INNER JOIN does not remain unmatched rows, so the ON clause work the same as WHERE clause.

-- 4
-- 50

-- 5
-- It joins the attributes that share the name

-- 6
-- It strongly relies on name given to attribute, so if the name is misspelled, the joining will be cancelled though it shouldn't be.

-- 7
-- SELECT * FROM B RIGHT JOIN A ON A.id = B.id

-- 8
-- To know the full information about 2 tables - which rows were matched and which were not
-- A
CREATE DATABASE advanced_lab;

CREATE TABLE employees (emp_id SERIAL PRIMARY KEY, first_name TEXT, last_name TEXT, department TEXT, salary INT, hire_date DATE, status TEXT DEFAULT 'ACTIVE');
CREATE TABLE departments (dept_id SERIAL PRIMARY KEY, dept_name TEXT, budget INT, manager_id INT);
CREATE TABLE projects (project_id SERIAL PRIMARY KEY, project_name TEXT, dept_id INT, start_date DATE, end_date DATE, budget INT);

-- B
INSERT INTO employees (emp_id, first_name, last_name, department) VALUES (1, 'John', 'Mantle', 'Milk');
INSERT INTO employees (salary, status) VALUES (DEFAULT, DEFAULT);
INSERT INTO departments (dept_name, budget, manager_id) VALUES ('Bread', 1000, 1), ('Plain', 1500, 3), ('Crain', 500, 1);
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES ('Bogdan', 'Bogdan', 'Milk', 55000, CURRENT_DATE, DEFAULT);
CREATE TABLE temp_employees AS (SELECT * FROM employees WHERE department = 'IT');

-- C
UPDATE employees SET salary = ROUND(salary * 1.1);
UPDATE employees SET status = 'Senior' WHERE salary > 60000 AND hire_date < '2020-01-01';
UPDATE employees SET department = CASE WHEN salary > 80000 THEN 'Management' WHEN salary <= 80000 AND salary > 50000 THEN 'Senior' ELSE 'Junior' END;
ALTER TABLE employees ALTER COLUMN department SET DEFAULT 'None';
UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';
UPDATE departments d SET budget = ROUND(1.2 * e.pipis) FROM (SELECT department, AVG(salary) AS pipis FROM employees GROUP BY department) e WHERE d.dept_name = e.department;
UPDATE employees SET salary = ROUND(salary * 1.15), status = 'Promoted' WHERE department = 'Sales';

-- D
DELETE FROM employees WHERE status = 'Terminated';
DELETE FROM employees WHERE salary < 40000 AND hire_date > '2023-01-01' AND department IS NULL;
DELETE FROM departments WHERE dept_name NOT IN (SELECT	DISTINCT	department	FROM	
employees	WHERE	department	IS	NOT	NULL);
DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

-- E
INSERT INTO employees (first_name, last_name, department, salary, hire_date, status) VALUES ('Old', 'Man', NULL, NULL, CURRENT_DATE, DEFAULT);
UPDATE employees SET department = 'Unassigned' WHERE department is NULL;
DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

-- F
INSERT INTO employees (first_name, last_name) VALUES ('John', 'John') RETURNING emp_id, first_name || ' ' || last_name AS full_name;
UPDATE employees SET salary = salary + 5000 WHERE department = 'IT' RETURNING emp_id, salary - 5000, salary;
DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

-- G
INSERT INTO employees (first_name, last_name) SELECT 'Susie', 'Gaster' WHERE NOT EXISTS (SELECT 1 FROM employees WHERE first_name = 'Susie' AND last_name = 'Gaster');
UPDATE employees e SET salary = ROUND(e.salary * CASE WHEN d.budget > 100000 THEN 1.1 ELSE 1.05 END) FROM departments d WHERE d.dept_name = e.department;
INSERT INTO employees (first_name, last_name, salary) VALUES ('Noelle', 'Gaster', 4000), ('Kris', 'Gaster', 6000), ('Mike', 'Gaster', 16600), ('John', 'Gaster', 4500), ('Johnny', 'Gaster', 4600);
UPDATE employees SET salary = ROUND(salary * 1.1) WHERE emp_id IN (SELECT emp_id FROM employees ORDER BY emp_id DESC LIMIT 5);
CREATE TABLE employee_archive AS (SELECT * FROM employees WHERE status = 'Inactive');
DELETE FROM employees WHERE status = 'Inactive';
UPDATE projects p SET end_date = p.end_date + 30 WHERE budget > 50000 AND (SELECT COUNT(DISTINCT e.emp_id) FROM employees e JOIN departments d ON d.dept_name = e.department WHERE p.dept_id = d.dept_id) > 3;

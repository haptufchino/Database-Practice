-- Create tables
CREATE TABLE departments (
 dept_id INT PRIMARY KEY,
 dept_name VARCHAR(50),
 location VARCHAR(50)
);
CREATE TABLE employees (
 emp_id INT PRIMARY KEY,
 emp_name VARCHAR(100),
 dept_id INT,
 salary DECIMAL(10,2),
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
 proj_id INT PRIMARY KEY,
 proj_name VARCHAR(100),
 budget DECIMAL(12,2),
 dept_id INT,
 FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
(101, 'IT', 'Building A'),
(102, 'HR', 'Building B'),
(103, 'Operations', 'Building C');
INSERT INTO employees VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 101, 55000),
(3, 'Mike Johnson', 102, 48000),
(4, 'Sarah Williams', 102, 52000),
(5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
(201, 'Website Redesign', 75000, 101),
(202, 'Database Migration', 120000, 101),
(203, 'HR System Upgrade', 50000, 102);


-- 2.1
CREATE INDEX emp_salary_idx ON employees(salary);
-- List all indexes on employees table
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'employees';
-- two indices

-- 2.2
CREATE INDEX emp_dept_idx ON employees(dept_id);
-- This query should use the index
SELECT * FROM employees WHERE dept_id = 101;
-- because it can help make join operations faster

-- 2.3
-- View all indexes in your database
SELECT
 tablename,
 indexname,
 indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- contacts_phone_number_key, contacts_pkey, departments_pkey, devices_pkey, emp_dept_idx, emp_salary_idx, employees_pkey, groups_name_key, groups_pkey, phones_pkey, projects_pkey
-- the ones with pkey subname

-- 3.1
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);
SELECT emp_name, salary 
FROM employees 
WHERE dept_id = 101 AND salary > 52000;
-- Yes, but it can be much slower for the query than a normal index

-- 3.2
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);
-- Query 1: Filters by dept_id first
SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- It matters only on effectiveness, the two queries return the same result. one order of columns can be more unique than other one.

-- 4.1
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);
-- This should fail with a unique violation error
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');
-- ERROR:  duplicate key value violates unique constraint "emp_email_unique_idx"

-- 4.2
-- Add a phone column with UNIQUE constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;
SELECT indexname, indexdef 
FROM pg_indexes 
WHERE tablename = 'employees' AND indexname LIKE '%phone%';
-- Yes, it created unique index

-- 5.1
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
SELECT emp_name, salary 
FROM employees 
ORDER BY salary DESC;
-- index stores rows sorted by itself, so order by dont need to do sorting every time

-- 5.2
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);
SELECT proj_name, budget 
FROM projects 
ORDER BY budget NULLS FIRST;

-- 6.1
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));
-- This query can use the expression index
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';
-- it would scan entire table and apply lower()

-- 6.2
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;

SELECT emp_name, hire_date 
FROM employees 
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- 7.1
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;
SELECT indexname FROM pg_indexes WHERE tablename = 'employees';

-- 7.2
DROP INDEX emp_salary_dept_idx;
-- if you want to load a chunk of new data

-- 7.3
REINDEX INDEX employees_salary_index;

-- 8.1

-- SELECT e.emp_name, e.salary, d.dept_name FROM employees e JOIN departments d ON e.dept_id = d.dept_id WHERE e.salary > 50000 ORDER BY e.salary DESC;

-- Index for the WHERE clause
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;

-- Index for the JOIN
-- CREATE INDEX emp_dept_idx ON employees(dept_id);
-- (already created: emp_dept_idx)

-- Index for ORDER BY
-- CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);
-- (already created: emp_salary_desc_idx)

-- 8.2
CREATE INDEX proj_high_budget_idx ON projects(budget) 
WHERE budget > 80000;
SELECT proj_name, budget 
FROM projects 
WHERE budget > 80000;
-- it indices the rows we actually need, not every one

-- 8.3
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
- Seq scan. it means that index is not in action

-- 9.1
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);
SELECT * FROM departments WHERE dept_name = 'IT'
-- when there is a need in comparing strings more effectively

-- 9.2
-- B-tree index
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
-- Hash index
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

-- 10.1
SELECT
 schemaname,
 tablename,
 indexname,
 pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- the ones with using hashes. because the hash indices use hash tables that require more memory

-- 10.2
-- Drop the duplicate expression indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- Keep only necessary indexes

-- 10.3
CREATE VIEW index_documentation AS
SELECT
 tablename,
 indexname,
 indexdef,
 'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
 AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;

-- 1
-- By default index uses B-tree

-- 2
-- When you need to use a certain column multiple times in WHERE, JOIN or ORDER BY operations

-- 3
-- When a table has small size and its more appropriate to just use seq scan, or when the columns you want to index are often modified and rarely used in queries

-- 4
-- On insert new index entries are inserted
-- on update affected index entries may be updated
-- on delete corresponding index entries are marked for removal and later cleaned up by VACUUM

-- 5
-- By using explain statement. in details it shows how scan was done, that let you determine use of index


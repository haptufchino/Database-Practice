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

-- 2.1
CREATE VIEW employee_details AS SELECT e.emp_name, e.salary, d.dept_name, d.location FROM employees e JOIN departments d USING (dept_id);
SELECT * FROM employee_details;
-- 4 rows were selected; Tom Brown wasnt included because he fails JOIN condition

-- 2.2
CREATE VIEW dept_statistics AS SELECT d.dept_name, COUNT(e.emp_id), AVG(e.salary), MAX(e.salary), MIN(e.salary) FROM departments d LEFT JOIN employees e USING (dept_id) GROUP BY d.dept_name;
SELECT * FROM dept_statistics
ORDER BY employee_count DESC;

-- 2.3
CREATE VIEW project_overview AS SELECT p.project_name, p.budget, d.dept_name, d.location, COUNT(e.emp_name) FROM projects p JOIN departments d USING (dept_id) JOIN employees e USING (dept_id) GROUP BY p.project_name, d.dept_name;

-- 2.4
CREATE VIEW high_earners AS SELECT e.emp_name, e.salary, d.dept_name FROM employees e JOIN departments d USING (dept_id) WHERE e.salary > 55000;

-- 3.1
CREATE OR REPLACE VIEW employee_details AS SELECT e.emp_name, e.salary, d.dept_name, d.location, CASE WHEN e.salary > 60000 THEN 'High' WHEN e.salary BETWEEN 60000 AND 50000 THEN 'Medium' ELSE 'Standard' END FROM employees e JOIN departments d USING (dept_id); 

-- 3.2
ALTER VIEW high_earners RENAME TO top_perfomers;
SELECT * FROM top_performers;

-- 3.3
CREATE VIEW temp_view AS SELECT emp_name FROM employees WHERE salary < 50000;
DROP VIEW temp_view;

-- 4.1
CREATE VIEW employee_salaries AS SELECT emp_id, emp_name, dept_id, salary FROM employees;

-- 4.2
UPDATE employee_salaries SET salary = 52000 WHERE emp_name = 'John Smith';
SELECT * FROM employees WHERE emp_name = 'John Smith';
-- Yes

-- 4.3
INSERT INTO employee_salaries (emp_id, emp_name, dept_id, salary) VALUES (6, 'Alice Johnson', 102, 58000);
-- Yes

-- 4.4
CREATE VIEW it_employees AS SELECT * FROM employees WHERE dept_id = 101 WITH CHECK OPTION;
-- This should fail
INSERT INTO it_employees (emp_id, emp_name, dept_id, salary)
VALUES (7, 'Bob Wilson', 103, 60000);
-- new row violates check option; it happens because the row has dept_id = 103, which does not satisfy the check option

-- 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS SELECT d.dept_id, d.dept_name, COUNT(e.emp_name), COALESCE(SUM(e.salary), 0), COUNT(p.project_name), COALESCE(SUM(p.budget), 0) FROM departments d JOIN employees e USING (dept_id) JOIN projects p USING (dept_id) GROUP BY d.dept_name WITH DATA;
SELECT * FROM dept_summary_mv ORDER BY total_employees DESC;

-- 5.2
INSERT INTO employees (emp_id, emp_name, dept_id, salary) VALUES (8, 'Charlie Brown', 101, 54000);
SELECT * FROM dept_summary_mv;
REFRESH MATERIALIZED VIEW dept_summary_mv;
SELECT * FROM dept_summary_mv;
-- The view data changed with refresh

-- 5.3
CREATE UNIQUE INDEX pp ON dept_summary_mv (dept_id);
REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;
-- In accessibility if there is flow in queries

-- 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS SELECT p.project_name, p.budget, d.dept_name, COUNT(e.emp_name) FROM projects p NATURAL JOIN departments d NATURAL JOIN employees e GROUP BY p.project_name WITH NO DATA;
SELECT * FROM project_stats_mv;
-- None error was raised, simply empty result with 0 rows. From now on updating view happens only with handle refreshing

-- 6.1
CREATE ROLE analyst;
CREATE ROLE data_viewer LOGIN PASSWORD 'viewer123';
CREATE USER report_user WITH PASSWORD 'report456';
SELECT rolname FROM pg_roles WHERE rolname NOT LIKE 'pg_%';

-- 6.2
CREATE ROLE db_creator LOGIN PASSWORD 'creator789' CREATEDB;
CREATE ROLE user_manager LOGIN PASSWORD 'manager101' CREATEROLE;
CREATE ROLE admin_user LOGIN PASSWORD 'admin999' SUPERUSER;

-- 6.3
GRANT SELECT ON employees, departments, projects TO analyst;
GRANT ALL PRIVILEGES ON employee_details TO data_viewer;
GRANT SELECT, INSERT ON employees TO report_user;

-- 6.4
CREATE ROLE hr_team NOLOGIN;
CREATE ROLE finance_team NOLOGIN;
CREATE ROLE it_team NOLOGIN;

CREATE ROLE hr_user1 LOGIN PASSWORD 'hr001';
CREATE ROLE hr_user2 LOGIN PASSWORD 'hr002';
CREATE ROLE finance_user1 LOGIN PASSWORD 'fin001';

GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

GRANT SELECT, UPDATE ON employees TO hr_team;
GRANT SELECT ON dept_statistics TO finance_team;

-- 6.5
REVOKE UPDATE ON employees FROM hr_team;
REVOKE hr_team FROM hr_user2;
REVOKE ALL PRIVILEGES ON employee_details FROM data_viewer;

-- 6.6 (gaster)
ALTER ROLE analyst WITH LOGIN;
ALTER ROLE analyst WITH PASSWORD 'analyst123';
ALTER ROLE user_manager WITH SUPERUSER;
ALTER ROLE analyst WITH PASSWORD NULL;
ALTER ROLE data_viewer WITH CONNECTION LIMIT 5;

-- 7.1
CREATE ROLE read_only NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO read_only;
CREATE USER junior_analyst WITH PASSWORD 'junior123';
CREATE USER senior_analyst WITH PASSWORD 'senior123';
GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;
GRANT INSERT, UPDATE ON ALL TABLES IN SCHEMA public TO senior_analyst;

-- 7.2
CREATE ROLE project_manager LOGIN PASSWORD 'pm123';
ALTER VIEW dept_statistics OWNER TO project_manager;
ALTER TABLE projects OWNER TO project_manager;

SELECT tablename, tableowner 
FROM pg_tables 
WHERE schemaname = 'public';

-- 7.3
CREATE ROLE temp_owner LOGIN;
CREATE TABLE temp_table (id INT);
ALTER TABLE temp_table OWNER TO temp_owner;
REASSIGN OWNED BY temp_owner TO postgres;
DROP TABLE temp_table;
DROP ROLE temp_owner;

-- 7.4
CREATE VIEW hr_employee_view AS SELECT emp_name FROM employees WHERE dept_id = 102;
GRANT SELECT ON hr_employee_viee TO hr_team;
CREATE VIEW finance_employee_view AS SELECT emp_id, emp_name, salary FROM employees;
GRANT SELECT ON finance_employee_view TO finance_team;

-- 8.1
CREATE VIEW dept_dashboard AS SELECT d.dept_name, d.location, COUNT(e.emp_name), ROUND(AVG(e.salary), 2), COUNT(p.project_name), SUM(p.budget), CASE WHEN COUNT(e.emp_name) = 0 THEN NULL ELSE ROUND(SUM(p.budget) / COUNT(e.emp_name), 2) END FROM departments d NATURAL JOIN employees e NATURAL JOIN projects p GROUP BY d.dept_name;

-- 8.2
ALTER TABLE projects ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
CREATE VIEW high_budget_projects AS SELECT * FROM projects WHERE budget > 75000;
ALTER TABLE projects ADD COLUMN approval_status VARCHAR(50);
UPDATE projects SET approval_status = CASE WHEN budget > 150000 THEN 'Critical Review Required' WHEN budget BETWEEN 100000 AND 150000 THEN 'Management Approval Needed' ELSE 'Standard Process' END;

-- 8.3
CREATE ROLE viewer_role NOLOGIN;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO viewer_role;

CREATE ROLE entry_role NOLOGIN;
GRANT viewer_role TO entry_role;
GRANT INSERT ON employees, projects TO entry_role;

CREATE ROLE analyst_role NOLOGIN;
GRANT entry_role TO analyst_role;
GRANT UPDATE ON employees, projects TO analyst_role;

CREATE ROLE manager_role NOLOGIN;
GRANT analyst_role TO manager_role;
GRANT DELETE ON employees, projects TO manager_role;

CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;
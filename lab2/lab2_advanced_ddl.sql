-- Task 1.1
CREATE DATABASE university_main OWNER haptufchino TEMPLATE template0 ENCODING 'UTF8';

CREATE DATABASE university_archive TEMPLATE template0 CONNECTION LIMIT 50;

CREATE DATABASE university_test conn_limit 10 IS_TEMPLATE TRUE;

-- Task 1.2
CREATE TABLESPACE student_data LOCATION '/data/students';

CREATE TABLESPACE course_data LOCATION'/data/courses' OWNER haptufchino;

CREATE DATABASE university_distributed TABLESPACE student_data ENCODING 'LATIN9';


-- Task 2.1, the database is university_main
CREATE TABLE students (student_id SERIAL PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), email VARCHAR(100), phone CHAR(15), date_of_birth DATE, enrollment_date DATE, gpa DECIMAL(3, 2), is_active BOOLEAN, graduation_year SMALLINT);

CREATE TABLE professors (professor_id SERIAL PRIMARY KEY, first_name VARCHAR(50), last_name VARCHAR(50), email VARCHAR(100), phone CHAR(15), office_number VARCHAR(20), hire_date DATE, salary DECIMAL(10, 2), is_tenured BOOLEAN, years_experienced SMALLINT);

CREATE TABLE courses (course_id SERIAL PRIMARY KEY, course_code CHAR(8), course_title VARCHAR(100), description TEXT, credits SMALLINT, max_enrollment INT, course_fee DECIMAL(10, 2), is_online BOOLEAN, created_at TIMESTAMP WITHOUT TIME ZONE);

-- Task 2.2
CREATE TABLE class_schedule (schedule_id SERIAL PRIMARY KEY, course_id INT, professor_id INT, classroom VARCHAR(20), class_date DATE, start_time TIME WITHOUT TIME ZONE, end_time TIME WITHOUT TIME ZONE, duration INTERVAL GENERATED ALWAYS AS (end_time - start_time) STORED);

CREATE TABLE student_records (record_id SERIAL PRIMARY KEY, student_id INT, course_id INT, semester VARCHAR(20), year INT, grade CHAR(2), attendance_percentage DECIMAL(10, 1), submission_timestamp TIMESTAMP WITH TIME ZONE, last_updated TIMESTAMP WITH TIME ZONE);


-- Task 3.1, the database is university_main
ALTER TABLE students ADD middle_name VARCHAR(30);
ALTER TABLE students ADD student_status VARCHAR(20);
ALTER TABLE students ALTER COLUMN phone SET TYPE VARCHAR(20);
ALTER TABLE students ALTER COLUMN is_active SET DEFAULT TRUE;
ALTER TABLE students ALTER COLUMN gpa SET DEFAULT 0.00;

ALTER TABLE professors ADD department_code CHAR(5);
ALTER TABLE professors ADD research_area TEXT;
ALTER TABLE professors ALTER COLUMN years_experienced SET TYPE SMALLINT;
ALTER TABLE professors ALTER COLUMN is_tenured SET DEFAULT FALSE;
ALTER TABLE professors ADD last_promotion_date DATE;

ALTER TABLE courses ADD prerequisite_course_id INT;
ALTER TABLE courses ADD difficulty_level SMALLINT;
ALTER TABLE courses ALTER COLUMN course_code SET TYPE VARCHAR(10);
ALTER TABLE courses ALTER COLUMN credits SET DEFAULT 3;
ALTER TABLE courses ADD lab_required BOOLEAN DEFAULT FALSE;


-- Task 3.2
ALTER TABLE class_schedule ADD room_capacity INT;
ALTER TABLE class_schedule DROP COLUMN duration;
ALTER TABLE class_schedule ADD session_type VARCHAR(15);
ALTER TABLE class_schedule ALTER COLUMN classroom SET TYPE VARCHAR(30);
ALTER TABLE class_schedule ADD equipment_needed TEXT;

ALTER TABLE student_records ADD extra_credit_points DECIMAL(10, 1);
ALTER TABLE student_records ALTER COLUMN grade SET TYPE VARCHAR(5); 
ALTER TABLE student_records ALTER COLUMN extra_credit_points SET DEFAULT 0.0;
ALTER TABLE student_records ADD final_exam_date DATE;
ALTER TABLE student_records DROP COLUMN last_updated;


-- Task 4.1, the database is university_main
CREATE TABLE departments (department_id SERIAL PRIMARY KEY, department_name VARCHAR(100), department_code CHAR(5), building VARCHAR(50), phone VARCHAR(15), budget DECIMAL(10, 2), established_year INT);

CREATE TABLE library_books (book_id SERIAL PRIMARY KEY, isbn CHAR(13), title VARCHAR(200), author VARCHAR(100), publisher VARCHAR(100), publication_date DATE, price DECIMAL(10, 2), is_available BOOLEAN, acquisition_timestamp TIMESTAMP WITHOUT TIME ZONE);

CREATE TABLE student_book_loans (loan_id SERIAL PRIMARY KEY, student_id INT, book_id INT, loan_date DATE, return_time DATE, fine_amount DECIMAL(10, 2), loan_status VARCHAR(20));


-- Task 4.2
ALTER TABLE professors ADD department_id INT;
ALTER TABLE students ADD advisor_id INT;
ALTER TABLE courses ADD department_id INT;

CREATE TABLE grade_scale (grade_id SERIAL PRIMARY KEY, letter_grade CHAR(2), min_percentage DECIMAL(10, 1), max_percentage DECIMAL(10, 1), gpa_points DECIMAL(10, 2));

CREATE TABLE semester_calendar (semester_id SERIAL PRIMARY KEY, semester_name VARCHAR(20), academic_year INT, start_date DATE, end_date DATE, registration_deadline TIMESTAMP WITH TIME ZONE, is_current BOOLEAN);


-- Task 5.1
DROP TABLE IF EXISTS student_loan_books;
DROP TABLE IF EXISTS library_books;
DROP TABLE IF EXISTS grade_scale;

CREATE TABLE grade_scale (grade_id SERIAL PRIMARY KEY, letter_grade CHAR(2), min_percentage DECIMAL(10, 1), max_percentage DECIMAL(10, 1), gpa_points DECIMAL(10, 2), description TEXT);

DROP TABLE semester_calendar CASCADE;
CREATE TABLE semester_calendar (semester_id SERIAL PRIMARY KEY, semester_name VARCHAR(20), academic_year INT, start_date DATE, end_date DATE, registration_deadline TIMESTAMP WITH TIME ZONE, is_current BOOLEAN);

-- Task 5.2
DROP DATABASE IF EXISTS university_test;
DROP DATABASE IF EXISTS university_distributed;
CREATE DATABASE university_backup TEMPLATE university_main;
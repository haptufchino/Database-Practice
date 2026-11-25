DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;
-- Create table: stations
CREATE TABLE stations (
station_id INT PRIMARY KEY,
station_name VARCHAR(50) NOT NULL,
city VARCHAR(40) NOT NULL,
capacity INT NOT NULL
);
-- Create table: bikes
CREATE TABLE bikes (
bike_id INT PRIMARY KEY,
model VARCHAR(50) NOT NULL,
station_id INT REFERENCES stations(station_id),
daily_rate NUMERIC(8,2) NOT NULL
);
-- Create table: members
CREATE TABLE members (
member_id INT PRIMARY KEY,
full_name VARCHAR(60) NOT NULL,
city VARCHAR(40) NOT NULL,
joined_on DATE NOT NULL
);
-- Create table: rentals
CREATE TABLE rentals (
rental_id INT PRIMARY KEY,
member_id INT REFERENCES members(member_id),
bike_id INT REFERENCES bikes(bike_id),
start_date DATE NOT NULL,
end_date DATE,
fee NUMERIC(8,2)
);

INSERT INTO stations VALUES
(10, 'Central Park', 'Almaty', 4),
(20, 'Riverside', 'Almaty', 3),
(30, 'Expo Gate', 'Astana', 5),
(40, 'Old Town', 'Shymkent', 2),
(50, 'Depot', 'Astana', 0);
INSERT INTO bikes VALUES
(101, 'City Cruiser', 10, 4.50),
(102, 'City Cruiser', 10, 4.50),
(103, 'Mountain X', 20, 7.00),
(104, 'Mountain X', 30, 7.00),
(105, 'Road Sprint', 30, 9.25),
(106, 'Folding Mini', 40, 3.75),
(107, 'Cargo Hauler', 20, 12.00),
(108, 'Road Sprint', 10, 9.25);
INSERT INTO members VALUES
(1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
(2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
(3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
(4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
(5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
(6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');
INSERT INTO rentals VALUES
( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02', 4.50),
( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
(10, 3, 104, DATE '2025-01-09', DATE '2025-01-10', 7.00),
(11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
(12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
(13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
(14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
(15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
(16, 5, 106, DATE '2025-01-18', DATE '2025-01-20', 7.50),
(17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
(18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
(19, 1, 101, DATE '2025-10-10', NULL, NULL),
(20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
(21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
(22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);

SELECT (SELECT COUNT(*) FROM stations) AS stations,
(SELECT COUNT(*) FROM bikes) AS bikes,
(SELECT COUNT(*) FROM members) AS members,
(SELECT COUNT(*) FROM rentals) AS rentals;

CREATE OR REPLACE FUNCTION inc(val INTEGER) RETURNS INTEGER AS $$
DECLARE
result INTEGER;
BEGIN
result := val + 1;
RETURN result;
END; $$
LANGUAGE plpgsql;
SELECT inc(10); -- 11

-- 2.1
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INTEGER) RETURNS INTEGER AS $$
DECLARE
pipis INTEGER;
BEGIN
  SELECT end_date - start_date INTO pipis FROM rentals WHERE rental_id = p_rental_id;
  RETURN pipis;
END;
$$ LANGUAGE plpgsql;
SELECT rental_days(19);
SELECT rental_days(999);
-- Null values for both, because first one has
-- null values in attrubutes, second one
-- is not in the table

-- 2.2
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INTEGER) RETURNS INTEGER AS $$
DECLARE
pipis INTEGER;
BEGIN
  SELECT COUNT(*) INTO pipis FROM rentals WHERE member_id = p_member_id;
  RETURN pipis;
END;
$$ LANGUAGE plpgsql;

SELECT member_rental_count(1); -- 5
SELECT member_rental_count(5); -- 4
SELECT member_rental_count(6); -- 0

-- 6 returns 0 because default value for count is 0, and logically its still correct

-- 2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT) RETURNS VARCHAR AS $$
DECLARE
pipis VARCHAR;
BEGIN
  SELECT city INTO pipis FROM stations WHERE station_id = p_station_id;
  RETURN pipis;
END;
$$ LANGUAGE plpgsql;

SELECT station_city(30); -- Astana
SELECT station_city(77); -- 

-- 2.4
SELECT rental_id, member_id, rental_days(rental_id) AS rd FROM rentals WHERE rental_days(rental_id) > 4 ORDER BY rd DESC;


-- 3.1
CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC) RETURNS DECIMAL AS $$
DECLARE
pipis DECIMAL(10, 2);
BEGIN
  pipis := p_fee * (1 - p_percent / 100); 
  RETURN pipis;
END;
$$ LANGUAGE plpgsql;

-- 3.2
CREATE OR REPLACE FUNCTION member_stats(
p_member_id INT,
OUT rental_cnt INT,
OUT total_fee NUMERIC,
OUT last_start DATE)
AS $$
BEGIN
  SELECT COUNT(*) INTO rental_cnt FROM rentals WHERE member_id = p_member_id;
  SELECT SUM(COALESCE(fee, 0)) INTO total_fee FROM rentals WHERE member_id = p_member_id;
  SELECT MAX(start_date) INTO last_start FROM rentals WHERE member_id = p_member_id;
END;
$$ LANGUAGE plpgsql;

SELECT member_stats(3);
SELECT * FROM member_stats(3);
-- One returns tuple, other one table
-- Second one preserves good structure, so it
-- is suitable for larger queries
-- for member 6: (0,,)

-- 3.3
CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC) 
AS $$
BEGIN
  p_fee := p_fee + 5.00;
END;
$$ LANGUAGE plpgsql;

SELECT apply_late_fee(1);
-- because inout mode does the process

-- 3.4
CREATE OR REPLACE FUNCTION fee_summary(
VARIADIC p_fees NUMERIC[],
OUT total NUMERIC,
OUT average NUMERIC,
OUT largest NUMERIC)
AS $$
BEGIN
  SELECT SUM(p_fees[i]), AVG(p_fees[i]), MAX(p_fees[i]) INTO total, average, largest FROM generate_subscripts(p_fees, 1) AS g(i);
END;
$$ LANGUAGE plpgsql;

SELECT * FROM fee_summary(13.50, 35.00, 18.50, 31.50);
-- With no arguments in error raising
-- Because variadic parameter take leftover
-- parameters that exceed the static number

-- 3.5
-- a - IN: row id is an input parameter
-- b - INOUT: input parameter needs to be updated, so it is also output
-- c - VARIADIC: list has unknown length
-- d - OUT: can return two values without converting into list

-- 4.1
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT) RETURNS NUMERIC
AS $$
DECLARE
  pipis INTEGER;
BEGIN
  SELECT SUM(fee) INTO pipis FROM rentals WHERE member_id = p_member_id;
  RETURN COALESCE(pipis, 0);
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1); -- 99
SELECT total_fees(6); -- 0

-- 4.2
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE) RETURNS NUMERIC
AS $$
DECLARE
  pipis INTEGER;
BEGIN
  SELECT SUM(fee) INTO pipis FROM rentals WHERE member_id = p_member_id AND start_date >= p_from_date;
  RETURN COALESCE(pipis, 0);
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1, DATE '2024-01-01');
SELECT total_fees(1, DATE '2025-01-01');

-- 4.3
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE DEFAULT DATE '2025-01-01') RETURNS NUMERIC
AS $$
DECLARE
  pipis INTEGER;
BEGIN
  SELECT SUM(fee) INTO pipis FROM rentals WHERE member_id = p_member_id AND start_date >= p_from_date;
  RETURN COALESCE(pipis, 0);
END;
$$ LANGUAGE plpgsql;

SELECT total_fees(1);
-- ERROR:  function total_fees(integer) is not unique
-- LINE 1: SELECT total_fees(1);
--               ^
-- HINT:  Could not choose a best candidate function. You might need to add explicit type casts.
-- one calls two functions simultaneously so
-- error raised

-- 4.4
DROP FUNCTION total_fees(INTEGER);
SELECT total_fees(1);
-- Second, the one for second, no because two
-- functions processes not the same

-- 4.5
CREATE OR REPLACE FUNCTION total_fees(p_member_name VARCHAR) RETURNS NUMERIC
AS $$
DECLARE
  pipis INTEGER;
BEGIN
  SELECT SUM(fee) INTO pipis FROM rentals r NATURAL JOIN members m WHERE m.full_name = p_member_name;
  RETURN COALESCE(pipis, 0);
END;
$$ LANGUAGE plpgsql;

SELECT total_fees('Aisha Nurlanova'); -- calls 3 function
SELECT total_fees(1); -- calls 2 function 
-- because their signatures different
-- second one uses date parameter, third one not

-- 5.1
CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR) 
RETURNS TABLE(found_id INT,
found_model VARCHAR, found_rate NUMERIC) as $$
BEGIN
  RETURN QUERY
  SELECT bike_id, model, daily_rate FROM bikes WHERE model ILIKE p_pattern ORDER BY bike_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM find_bikes('%road%');
SELECT * FROM find_bikes('%Mini');
SELECT find_bikes('%road%');
-- returns tuple because it is now result
-- of function, not query

-- 5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT) 
RETURNS TABLE(r_id INT,
b_model VARCHAR, b_station VARCHAR, r_days INT, fee NUMERIC) as $$
BEGIN
  RETURN QUERY
  SELECT r.rental_id, b.model, s.station_name, rental_days(r.rental_id), r.fee FROM rentals r NATURAL JOIN bikes b NATURAL JOIN stations s WHERE r.member_id = p_member_id ORDER BY r.start_date;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM member_history(3);

-- 5.3
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);

-- ERROR:  column reference "bike_id" is ambiguous
-- LINE 1: SELECT bike_id, model FROM bikes WHERE station_id = p_statio...
--                ^
-- DETAIL:  It could refer to either a PL/pgSQL variable or a table column.
-- QUERY:  SELECT bike_id, model FROM bikes WHERE station_id = p_station_id

DROP FUNCTION bike_list(INTEGER);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (p_bike_id INT, p_model VARCHAR) AS $$
BEGIN
RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);

DROP FUNCTION bike_list(INTEGER);

CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
RETURN QUERY SELECT bike_id AS p_id, model AS p_model FROM bikes WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;
SELECT * FROM bike_list(10);
-- ERROR:  column reference "bike_id" is ambiguous

-- 5.4
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
  RETURN QUERY 
  SELECT s.station_name, COUNT(b.bike_id), s.capacity - COUNT(b.bike_id) FROM stations s NATURAL JOIN bikes b WHERE s.city = p_city GROUP BY s.station_id, s.station_name, s.capacity;
END; 
$$ LANGUAGE plpgsql;
SELECT * FROM station_board('Almaty');
-- ERROR:  structure of query does not match function result type
-- DETAIL:  Returned type bigint does not match expected type integer in column "s_bikes" (position 2).

DROP FUNCTION station_board(VARCHAR);
CREATE OR REPLACE FUNCTION station_board(p_city VARCHAR)
RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
  RETURN QUERY 
  SELECT s.station_name, (COUNT(b.bike_id))::INT, (s.capacity - COUNT(b.bike_id))::INT FROM stations s NATURAL JOIN bikes b WHERE s.city = p_city GROUP BY s.station_id, s.station_name, s.capacity;
END; 
$$ LANGUAGE plpgsql;
SELECT * FROM station_board('Almaty');

-- 6.1
DO $$
<<rental_report>>
DECLARE
total_rentals INTEGER := 0;
BEGIN
  SELECT COUNT(*) INTO total_rentals FROM rentals;
  RAISE NOTICE 'The rentals table holds % rows', total_rentals;
END rental_report $$;
-- syntax error if the end label not matching the top one

-- 6.2
DO $$
<<rental_report>>
DECLARE
  fee_total NUMERIC;
BEGIN
  SELECT SUM(fee) INTO fee_total FROM rentals;
  RAISE NOTICE 'Outer fee_total before subblock: %', fee_total;

  DECLARE
    fee_total NUMERIC;
  BEGIN
    SELECT SUM(fee) INTO fee_total
    FROM rentals
    WHERE start_date >= '2025-01-01';
    RAISE NOTICE 'Subblock fee_total: %', fee_total;
    RAISE NOTICE 'Outer fee_total from subblock: %',
      rental_report.fee_total;
  END;

  RAISE NOTICE 'Outer fee_total after subblock: %', fee_total;
END rental_report;
$$;
-- NOTICE:  Outer fee_total before subblock: 621.50
-- NOTICE:  Subblock fee_total: 369.00
-- NOTICE:  Outer fee_total from subblock: 621.50
-- NOTICE:  Outer fee_total after subblock: 621.50
-- Subblock didnt change the fee_total of outer block, because it assigns it only inside like the friend inside me

-- 6.3
DO $$
<<rental_report>>
DECLARE
  fee_total NUMERIC;
BEGIN
  SELECT SUM(fee) INTO fee_total FROM rentals;
  RAISE NOTICE 'Outer fee_total before subblock: %', fee_total;

  DECLARE
    inner_fee NUMERIC;
  BEGIN
    SELECT SUM(fee) INTO inner_fee
    FROM rentals
    WHERE start_date >= '2025-01-01';
    RAISE NOTICE 'Subblock fee_total: %', inner_fee;
    RAISE NOTICE 'Outer fee_total from subblock: %',
      rental_report.fee_total;
  END;
  
  DECLARE
  BEGIN
    RAISE NOTICE 'Inner:%', inner_fee;
  END;

  RAISE NOTICE 'Outer fee_total after subblock: %', fee_total;
END rental_report;
$$;
-- ERROR:  column "inner_fee" does not exist

DO $$
<<rental_report>>
DECLARE
  fee_total NUMERIC;
  inner_fee NUMERIC;
BEGIN
  SELECT SUM(fee) INTO fee_total FROM rentals;
  RAISE NOTICE 'Outer fee_total before subblock: %', fee_total;

  DECLARE
  BEGIN
    SELECT SUM(fee) INTO inner_fee
    FROM rentals
    WHERE start_date >= '2025-01-01';
    RAISE NOTICE 'Subblock fee_total: %', inner_fee;
    RAISE NOTICE 'Outer fee_total from subblock: %',
      rental_report.fee_total;
  END;
  
  DECLARE
  BEGIN
    RAISE NOTICE 'Inner:%', inner_fee;
  END;

  RAISE NOTICE 'Outer fee_total after subblock: %', fee_total;
END rental_report;
$$;

-- 6.4
CREATE OR REPLACE FUNCTION fee_split(p_from_date DATE, OUT before_total NUMERIC, OUT after_total NUMERIC) AS $$
BEGIN
  SELECT COALESCE(SUM(fee), 0) INTO before_total FROM rentals WHERE start_date < p_from_date;
  SELECT COALESCE(SUM(fee), 0) INTO after_total FROM rentals WHERE start_date >= p_from_date;
END;
$$ LANGUAGE plpgsql;

SELECT before_total, after_total, before_total + after_total AS split_total, (SELECT SUM(fee) FROM rentals) AS whole_total FROM fee_split('2025-01-01');

-- 7.1
CREATE OR REPLACE FUNCTION  station_load(p_station_id INT, OUT bikes_parked INT, OUT capacity_pct NUMERIC) AS $$
BEGIN
  SELECT COUNT(b.bike_id)::INT, CASE WHEN s.capacity = 0 THEN -1 ELSE ROUND(COUNT(b.bike_id)::NUMERIC / s.capacity * 100, 2) END INTO bikes_parked, capacity_pct FROM stations s NATURAL JOIN bikes b WHERE s.station_id = p_station_id GROUP BY s.capacity;
END;
$$ LANGUAGE plpgsql;

-- 7.2
CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (member_name VARCHAR, rental_count BIGINT, total_spent NUMERIC) AS $$
BEGIN
  RETURN QUERY
  SELECT m.full_name, COUNT(r.rental_id), COALESCE(SUM(r.fee), 0) FROM members m NATURAL JOIN rentals r GROUP BY m.member_id, m.full_name ORDER BY COALESCE(SUM(r.fee), 0) DESC LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM top_members();
SELECT * FROM top_members(6);
-- the order is correct because it is ordered
-- in total spent

-- 7.3
CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (member_name VARCHAR, bike_model VARCHAR, rental_days INT, amount_owed NUMERIC, status VARCHAR)
AS $$
BEGIN
  RETURN QUERY
  SELECT m.full_name, b.model, (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT, ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::NUMERIC * b.daily_rate, 2), CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END::VARCHAR
  FROM rentals r
  JOIN members m ON m.member_id = r.member_id
  JOIN bikes b ON b.bike_id = r.bike_id
  WHERE r.rental_id = p_rental_id;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM rental_invoice(11);
SELECT * FROM rental_invoice(19);
-- 11: yes it does
-- 19: because end_date is NULL so CURREND_DATE used
-- function depending on current_date is not immutable, it is stable

-- 7.4
CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR)
RETURNS TABLE (member_count BIGINT, rental_count BIGINT, total_revenue NUMERIC)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM members WHERE city = p_city),
    COUNT(r.rental_id),
    COALESCE(SUM(r.fee), 0)
  FROM members m
  LEFT JOIN rentals r ON r.member_id = m.member_id
  WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE (member_count BIGINT, rental_count BIGINT, total_revenue NUMERIC)
AS $$
BEGIN
  RETURN QUERY
  SELECT
    (SELECT COUNT(*) FROM members WHERE city = p_city),
    COUNT(r.rental_id),
    COALESCE(SUM(r.fee), 0)
  FROM members m
  LEFT JOIN rentals r ON r.member_id = m.member_id
    AND r.start_date >= p_from_date
  WHERE m.city = p_city;
END;
$$ LANGUAGE plpgsql;

SELECT * FROM city_report('Almaty');
SELECT * FROM city_report('Almaty', '2025-01-01');
-- date condition belongs to on clause
-- because where clause exclude members
-- with no rentals, which is not we needed
-- so the difference is that where returns
-- less members

-- 1
-- name is needed for calling, signature for defining function

-- 2
-- it allows writing strings without escaping single quotes
-- BEGIN
-- RAISE NOTICE 'User's rental is open';
-- END;
-- without dollar quoting, the function body would require escaping or changing the outer string delimiter

-- 3
-- out: for statistic
-- returns table: for whole table

-- 4
-- because variadic works like the end of bridge, there can be added parameters on the end, but you cant put it in the middle
-- Hypothetical invalid order:
-- f(VARIADIC nums INT[], limit INT)

-- 5
-- return: returns value
-- return query: returns result of query

-- 6
-- because with default a call may call two functions simultaneously which raises error
-- by by checking existing overloads and testing calls before deploying changes

-- 7
-- it disappears
-- by using outer block label

-- 8
-- advantage: rules are centralized and consistently applied by different applications
-- disadvantage: business logic becomes dependent on the database, making maintenance and testing potentially more difficult

-- 9
-- pgsql: users with the privileges can create functions
-- python: only superusers can create functions

-- 10
-- overload happens, so the both functions remain which can cause ambiguity
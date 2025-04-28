SET ROLE postgres;
CREATE DATABASE approach5;
ALTER DATABASE approach5 SET session_preload_libraries = 'anon';

\c approach5

DROP TABLE IF EXISTS users;

-- Create table
CREATE TABLE IF NOT EXISTS users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),                  -- Non-sensitive data
    salary INT NOT NULL,                -- Sensitive data
    role VARCHAR(100) NOT NULL
);

-- Insert data
INSERT INTO users (id, name, salary, role) 
VALUES 
    (1, 'John Doe', 100000, 'engineer_manager'),
    (2, 'Jane Smith', 99999, 'engineer_member'), 
    (3, 'Bob Brown', 99998, 'marketing_manager'), 
    (4, 'Charlie Davis', 99997, 'marketing_member');

GRANT SELECT ON users TO engineer_manager, marketing_manager, engineer_member, marketing_member;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Grant login permission
ALTER ROLE engineer_member WITH LOGIN;
ALTER ROLE engineer_manager WITH LOGIN;


-- Create policies
CREATE POLICY member_policy ON users TO engineer_member
USING (
    role = 'engineer_member'
);

CREATE POLICY manager_policy ON users TO engineer_manager
USING (
    role = 'engineer_manager' OR role = 'engineer_member'
);

-- Create the anon extension
CREATE EXTENSION IF NOT EXISTS anon CASCADE;
SELECT anon.start_dynamic_masking();


SECURITY LABEL FOR anon ON ROLE engineer_member IS 'MASKED';
SECURITY LABEL FOR anon ON ROLE engineer_manager IS NULL;
SECURITY LABEL FOR anon ON COLUMN users.salary IS 'MASKED WITH VALUE 0';

\c - engineer_member
SELECT * FROM users;

\c - engineer_manager
SELECT * FROM users;

-- CREATE TABLE people ( id TEXT, firstname TEXT, lastname TEXT, phone TEXT);
-- INSERT INTO people VALUES ('T1','Sarah', 'Conor','0609110911');
-- SELECT * FROM people;

-- CREATE EXTENSION IF NOT EXISTS anon CASCADE;
-- SELECT anon.start_dynamic_masking();

-- CREATE ROLE skynet LOGIN;
-- CREATE ROLE aaa LOGIN;

-- GRANT SELECT ON people TO skynet, aaa;

-- \dp people;

-- SECURITY LABEL FOR anon ON ROLE skynet
-- IS 'MASKED';
-- SECURITY LABEL FOR anon ON ROLE aaa
-- IS NULL;


-- SECURITY LABEL FOR anon ON COLUMN people.phone
-- IS 'MASKED WITH FUNCTION anon.partial(phone,2,$$******$$,2)';

-- \c - skynet
-- SELECT * FROM people;

-- \c - aaa
-- SELECT * FROM people;
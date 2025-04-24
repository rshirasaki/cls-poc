CREATE DATABASE approach1;

\c approach1

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

-- Create roles
CREATE ROLE engineer_member WITH PASSWORD 'password';
CREATE ROLE engineer_manager WITH PASSWORD 'password';
CREATE ROLE marketing_member WITH PASSWORD 'password';
CREATE ROLE marketing_manager WITH PASSWORD 'password';

GRANT SELECT ON users TO engineer_manager, marketing_manager;
GRANT SELECT (id, name, role) ON users TO engineer_member, marketing_member;

ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY member_policy ON users TO engineer_member, marketing_member
USING (
    role = current_user                 -- Unique at this PoC
);

CREATE POLICY engineer_manager_policy ON users TO engineer_manager
USING (
    role = 'engineer_manager' OR role = 'engineer_member'
);

CREATE POLICY marketing_manager_policy ON users TO marketing_manager
USING (
    role = 'marketing_manager' OR role = 'marketing_member'
);

-- Test the policies
SET ROLE engineer_manager;
SELECT * FROM users;                    -- OK

SET ROLE engineer_member;
SELECT (id, name, role) FROM users;      -- OK
--SELECT * FROM users;                   -- ERROR:  permission denied for table users

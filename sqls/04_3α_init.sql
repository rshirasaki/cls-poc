SET ROLE root;
CREATE DATABASE approach4;

\c approach4

DROP TABLE IF EXISTS users;

CREATE ROLE admin_member WITH PASSWORD 'password';
CREATE ROLE admin_manager WITH PASSWORD 'password';

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


GRANT SELECT ON users TO admin_manager, admin_member;

-- Enable row level security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY member_policy ON users TO engineer_member, marketing_member, admin_member
USING (
    role = current_user                 -- Unique at this PoC
);

CREATE POLICY engineer_manager_policy ON users TO engineer_manager, admin_manager
USING (
    role = 'engineer_manager' OR role = 'engineer_member'
);

CREATE POLICY marketing_manager_policy ON users TO marketing_manager
USING (
    role = 'marketing_manager' OR role = 'marketing_member'
);

GRANT CREATE ON SCHEMA public TO admin_manager, admin_member;

SET ROLE admin_manager;

CREATE VIEW users_for_managers AS
SELECT
    id,
    name,
    role,
    salary
FROM users;

GRANT SELECT ON users_for_managers TO engineer_manager, marketing_manager;

SET ROLE admin_member;

CREATE VIEW users_for_members AS
SELECT
    id,
    name,
    role,
    NULL AS salary
FROM users;

GRANT SELECT ON users_for_members TO engineer_member, marketing_member;

-- Test the view
SET ROLE engineer_manager;
SELECT * FROM users_for_managers;

SET ROLE engineer_member;
SELECT * FROM users_for_members;

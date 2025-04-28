SET ROLE postgres;
CREATE DATABASE approach3;

\c approach3

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

-- Enable row level security
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

CREATE VIEW users_mask AS
SELECT 
    id, 
    name, 
    role, 
    CASE
        WHEN current_user = 'engineer_manager' AND role LIKE 'engineer%' THEN salary
        WHEN current_user = 'marketing_manager' AND role LIKE 'marketing%' THEN salary
        WHEN current_user = 'engineer_member' AND role = 'engineer_member' THEN salary
        WHEN current_user = 'marketing_member' AND role = 'marketing_member' THEN salary
        ELSE NULL
    END AS salary
FROM users;

GRANT SELECT ON users_mask TO engineer_manager, marketing_manager, engineer_member, marketing_member;

-- Test the view
SET ROLE engineer_manager;
SELECT * FROM users_mask;

SET ROLE engineer_member;
SELECT * FROM users_mask;

SET ROLE postgres;
CREATE DATABASE approach6;

\c approach6

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    salary INT NOT NULL,
    role VARCHAR(100) NOT NULL
);

CREATE ROLE app_user WITH LOGIN;

INSERT INTO users (id, name, salary, role) 
VALUES 
    (1, 'John Doe', 100000, 'engineer_manager'),
    (2, 'Jane Smith', 99999, 'engineer_member'), 
    (3, 'Bob Brown', 99998, 'marketing_manager'), 
    (4, 'Charlie Davis', 99997, 'marketing_member');
-- 管理者も含めて、users テーブルを直接叩けないようにする
GRANT SELECT ON users TO engineer_manager, marketing_manager, engineer_member, marketing_member;
GRANT SELECT ON users TO app_user;

-- 2) RLS を有効化＆ポリシー定義（既存のまま）
ALTER TABLE users ENABLE ROW LEVEL SECURITY;

CREATE POLICY engineer_manager_policy ON users
  FOR SELECT
  USING (
    current_setting('app.role', TRUE) = 'engineer_manager'
    AND role IN ('engineer_manager','engineer_member')
  );

CREATE POLICY engineer_member_policy ON users
  FOR SELECT
  USING (
    current_setting('app.role', TRUE) = 'engineer_member'
    AND role = 'engineer_member'
  );


CREATE OR REPLACE FUNCTION get_users()
  RETURNS TABLE (
    id     INT,
    name   VARCHAR(100),
    salary INT,
    role   VARCHAR(100)
  )
  LANGUAGE sql
  SECURITY INVOKER
AS $$
  SELECT
    id,
    name,
    -- マネージャーなら salary、メンバーなら NULL
    CASE
      WHEN current_setting('app.role', TRUE) LIKE '%manager' THEN salary
      ELSE NULL
    END AS salary,
    role
  FROM users;
$$;

\c - app_user
BEGIN;
    SELECT set_config('app.role','engineer_member',TRUE);
    SELECT current_setting('app.role', TRUE);
    SELECT * FROM get_users();
COMMIT;

BEGIN;
    SELECT set_config('app.role','engineer_manager',TRUE);
    SELECT current_setting('app.role', TRUE);
    SELECT * FROM get_users();
COMMIT;

-- Create a group
CREATE ROLE readaccess;

-- Grant access to existing tables
GRANT USAGE ON SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO readaccess;
GRANT SELECT ON ALL TABLES IN SCHEMA public TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA payroll TO postgres;
GRANT SELECT ON ALL TABLES IN SCHEMA edi TO postgres;

-- Grant access to future tables
ALTER DEFAULT PRIVILEGES IN SCHEMA public GRANT SELECT ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA payroll GRANT SELECT ON TABLES TO postgres;
ALTER DEFAULT PRIVILEGES IN SCHEMA edi GRANT SELECT ON TABLES TO postgres;

-- Create a final user with password
CREATE USER ehcmuser WITH PASSWORD 'secret';
GRANT readaccess TO ehcmuser;

CREATE USER read_only WITH PASSWORD 'secret';
GRANT readaccess TO read_only;

CREATE USER read_write WITH PASSWORD 'secret';
GRANT readaccess TO read_write;

CREATE USER skybotsu WITH PASSWORD 'secret';
GRANT readaccess TO skybotsu;

CREATE USER postgres WITH PASSWORD 'secret';
GRANT readaccess TO postgres;

GRANT USAGE  ON SCHEMA  TO schma_usr;
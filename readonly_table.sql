-- Make a table readonly

-- Use the rideshare_development database as an example
-- Mark the "trips" table readonly

BEGIN;

-- Revoke all privileges from rideshare.trips
REVOKE ALL PRIVILEGES ON TABLE trips FROM owner;

-- Grant SELECT privilege to application user ("owner")
GRANT SELECT ON TABLE trips TO owner;

COMMIT; -- commit these together

-- Try and insert into the table as "owner"
-- get "permission denied"

owner@localhost:5432 rideshare_development# insert into trips (trip_request_id, driver_id, completed_at, rating, created_at, updated_at) values (1, 1, NULL, NULL, now(), now());
ERROR:  permission denied for table trips

-- Restore original privs: (run as superuser)
-- set search_path = 'rideshare';
-- List privs as a grant statement
SELECT
    'GRANT ' || array_to_string(array_agg(privilege_type), ', ') || ' ON TABLE ' || table_name || ' TO ' || grantee || ';' AS grant_statement
FROM (
    SELECT
        grantee,
        table_name,
        privilege_type
    FROM
        information_schema.role_table_grants
    WHERE
        table_name = 'trips'
) AS privileges
GROUP BY
    grantee, table_name;

grant_statement
----------------------------------------------------------------------------------------------
 GRANT INSERT, SELECT, UPDATE, DELETE, TRUNCATE, REFERENCES, TRIGGER ON TABLE trips TO owner;
 GRANT SELECT ON TABLE trips TO readonly_users;
 GRANT INSERT, SELECT, UPDATE, DELETE ON TABLE trips TO readwrite_users;

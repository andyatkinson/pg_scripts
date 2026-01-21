-- Queries from pg_stat_statements related to the app
WITH user_oid AS (
    SELECT
        oid
    FROM
        pg_roles
    WHERE
        rolname = CURRENT_USER
),
db_oid AS (
    SELECT
        oid
    FROM
        pg_database
    WHERE
        datname = current_database())
SELECT
    *
FROM
    pg_stat_statements pgss
    JOIN user_oid ON pgss.userid = user_oid.oid
    JOIN db_oid ON pgss.dbid = db_oid.oid
        AND query NOT LIKE 'set client_encoding%'
        AND query NOT LIKE 'set role%'
        AND query NOT LIKE 'SET %'
        AND query NOT LIKE 'SELECT set_config%'
        AND query NOT LIKE 'ANALYZE %'
        AND query NOT LIKE 'SELECT tableoid%'
        AND query NOT LIKE 'SELECT current_database()'
        AND query NOT LIKE 'BEGIN'
        AND query NOT LIKE 'COMMIT'
        AND query NOT LIKE '%FROM pg_stat_statements%'
        AND query NOT LIKE '%pg_catalog.pg_get_triggerdef%'
        AND query NOT LIKE 'SHOW %'
        AND query NOT LIKE '%FROM pg_attribute a%'
        AND query NOT LIKE '%FROM pg_class%'
        AND query NOT LIKE '%FROM pg_namespace%'
        AND query NOT LIKE '%FROM pg_catalog.pg_namespace%'
        AND query NOT LIKE '%FROM pg_default_acl%'
        AND query NOT LIKE '%pg_constraint%'
        AND query NOT LIKE '%pg_inherits%'
        AND query NOT LIKE '%pg_catalog.pg_attrdef%'
        AND query NOT LIKE '%FROM pg_type%'
        AND query NOT LIKE '%FROM pg_depend%'
        AND query NOT LIKE 'PREPARE dumpEnumType%'
        AND query NOT LIKE '%FROM pg_catalog.pg_enum%'
        AND query NOT LIKE '%pg_catalog.pg_get_userbyid%'
        AND query NOT LIKE 'SELECT pg_catalog.set_config%'
        AND query NOT LIKE '%JOIN pg_attribute%'
        AND query NOT LIKE 'SELECT format_type%'
        AND query NOT LIKE '%pg_catalog.format_type%'
        AND query NOT LIKE 'PREPARE dumpFunc%'
        AND query NOT LIKE 'SELECT pg_catalog.pg_is_in_recovery()'
        AND query NOT LIKE '%FROM pg_subscription%'
        AND query NOT LIKE '%pg_catalog.pg_roles%'
        AND query NOT LIKE '%FROM pg_extension%'
        AND query NOT LIKE '%FROM pg_publication%'
        AND query NOT LIKE '%pg_catalog.current_schemas%'
        AND query NOT LIKE '%FROM pg_event_trigger%'
        AND query NOT LIKE '%pg_catalog.pg_description%'
        AND query NOT LIKE '%pg_catalog.pg_seclabel%'
        AND query NOT LIKE 'SELECT pg_catalog.pg_get_viewdef%';

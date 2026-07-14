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
        AND query NOT ILIKE 'set client_encoding%'
        AND query NOT ILIKE 'set role%'
        AND query NOT ILIKE 'SET %'
        AND query NOT ILIKE 'SELECT set_config%'
        AND query NOT ILIKE 'ANALYZE %'
        AND query NOT ILIKE 'SELECT tableoid%'
        AND query NOT ILIKE 'SELECT current_database()'
        AND query NOT ILIKE 'BEGIN'
        AND query NOT ILIKE 'COMMIT'
        AND query NOT ILIKE '%FROM pg_stat_statements%'
        AND query NOT ILIKE '%pg_catalog.pg_get_triggerdef%'
        AND query NOT ILIKE 'SHOW %'
        AND query NOT ILIKE '%FROM pg_attribute a%'
        AND query NOT ILIKE '%FROM pg_class%'
        AND query NOT ILIKE '%FROM pg_namespace%'
        AND query NOT ILIKE '%FROM pg_catalog.pg_namespace%'
        AND query NOT ILIKE '%FROM pg_default_acl%'
        AND query NOT ILIKE '%pg_constraint%'
        AND query NOT ILIKE '%pg_inherits%'
        AND query NOT ILIKE '%pg_catalog.pg_attrdef%'
        AND query NOT ILIKE '%FROM pg_type%'
        AND query NOT ILIKE '%FROM pg_depend%'
        AND query NOT ILIKE 'PREPARE dumpEnumType%'
        AND query NOT ILIKE '%FROM pg_catalog.pg_enum%'
        AND query NOT ILIKE '%pg_catalog.pg_get_userbyid%'
        AND query NOT ILIKE 'SELECT pg_catalog.set_config%'
        AND query NOT ILIKE '%JOIN pg_attribute%'
        AND query NOT ILIKE 'SELECT format_type%'
        AND query NOT ILIKE '%pg_catalog.format_type%'
        AND query NOT ILIKE 'PREPARE dumpFunc%'
        AND query NOT ILIKE 'SELECT pg_catalog.pg_is_in_recovery()'
        AND query NOT ILIKE '%FROM pg_subscription%'
        AND query NOT ILIKE '%pg_catalog.pg_roles%'
        AND query NOT ILIKE '%FROM pg_extension%'
        AND query NOT ILIKE '%FROM pg_publication%'
        AND query NOT ILIKE '%pg_catalog.current_schemas%'
        AND query NOT ILIKE '%FROM pg_event_trigger%'
        AND query NOT ILIKE '%pg_catalog.pg_description%'
        AND query NOT ILIKE '%pg_catalog.pg_seclabel%'
        AND query NOT ILIKE 'SELECT pg_catalog.pg_get_viewdef%'
        AND query NOT ILIKE 'select version%'
        AND query NOT ILIKE 'select * from pg_stat_statements%'
        AND query NOT ILIKE 'SELECT current_schema()%'
        AND query NOT ILIKE 'SELECT current_user%'
        AND query NOT ILIKE 'WITH user_oid AS%'
        AND query NOT ILIKE 'select current_user, current_schema()%';

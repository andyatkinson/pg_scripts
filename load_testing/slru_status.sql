SELECT * FROM pg_stat_slru WHERE name = 'MultiXactMember' OR name = 'MultiXactOffset';

-- multixact age
SELECT
    datname,
    age(datminmxid) AS multixact_age
FROM
    pg_database
ORDER BY
    multixact_age DESC;


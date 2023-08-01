-- credit: https://dataedo.com/kb/query/postgresql/find-tables-with-specific-column-name
-- formatted to taste
SELECT
  t.table_schema,
  t.table_name
FROM
  information_schema.tables t
  INNER JOIN
    information_schema.columns c
    ON c.table_name = t.table_name
    AND c.table_schema = t.table_schema
WHERE
  c.column_name = '<column>'
  AND t.table_schema NOT IN
  (
    'information_schema',
    'pg_catalog'
  )
  AND t.table_type = 'BASE TABLE'
ORDER BY
  t.table_schema;

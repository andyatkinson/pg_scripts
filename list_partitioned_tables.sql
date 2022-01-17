--
-- https://stackoverflow.com/a/58243669
-- r = ordinary table, i = index, S = sequence, t = TOAST table, v = view,
-- m = materialized view, c = composite type, f = foreign table,
-- p = partitioned table, I = partitioned index
--
SELECT n.nspname AS "Schema"
     , c.relname AS "Name"
     , CASE c.relkind
         WHEN 'p' THEN 'partitioned table'
         WHEN 'r' THEN 'ordinary table'
         -- more types?
         ELSE 'unknown table type'
       END AS "Type"
     , pg_catalog.pg_get_userbyid(c.relowner) AS "Owner"
FROM   pg_catalog.pg_class c
JOIN   pg_catalog.pg_namespace n ON n.oid = c.relnamespace
WHERE  c.relkind = ANY ('{p,r,""}') -- add more types?
AND    NOT c.relispartition         -- exclude child partitions
AND    n.nspname !~ ALL ('{^pg_,^information_schema$}') -- exclude system schemas
ORDER  BY 1, 2;

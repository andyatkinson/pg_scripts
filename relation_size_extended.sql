-- This works across all tables, and for partitioned tables
-- sums up the sizes of the leaf partitions as well. Nice!
-- https://stackoverflow.com/a/59266949/126688
--
WITH RECURSIVE tables AS (
  SELECT
    c.oid AS parent,
    c.oid AS relid,
    1     AS level
  FROM pg_catalog.pg_class c
  LEFT JOIN pg_catalog.pg_inherits AS i ON c.oid = i.inhrelid
    -- p = partitioned table, r = normal table
  WHERE c.relkind IN ('p', 'r')
    -- not having a parent table -> we only get the partition heads
    AND i.inhrelid IS NULL
  UNION ALL
  SELECT
    p.parent         AS parent,
    c.oid            AS relid,
    p.level + 1      AS level
  FROM tables AS p
  LEFT JOIN pg_catalog.pg_inherits AS i ON p.relid = i.inhparent
  LEFT JOIN pg_catalog.pg_class AS c ON c.oid = i.inhrelid AND c.relispartition
  WHERE c.oid IS NOT NULL
)
SELECT
  parent ::REGCLASS                                  AS table_name,
  array_agg(relid :: REGCLASS)                       AS all_partitions,
  pg_size_pretty(sum(pg_total_relation_size(relid))) AS pretty_total_size,
  sum(pg_total_relation_size(relid))                 AS total_size
FROM tables
GROUP BY parent
ORDER BY sum(pg_total_relation_size(relid)) DESC;





-- This prints results only for partitioned tables
-- It shows various size metrics about the partitioned tables. Very nice.
-- https://stackoverflow.com/a/54943758/126688
--
SELECT
   pi.inhparent::regclass AS parent_table_name, 
   pg_size_pretty(sum(pg_total_relation_size(psu.relid))) AS total,
   pg_size_pretty(sum(pg_relation_size(psu.relid))) AS internal,
   pg_size_pretty(sum(pg_table_size(psu.relid) - pg_relation_size(psu.relid))) AS external, -- toast
   pg_size_pretty(sum(pg_indexes_size(psu.relid))) AS indexes
FROM pg_catalog.pg_statio_user_tables psu
   JOIN pg_class pc ON psu.relname = pc.relname
   JOIN pg_database pd ON pc.relowner = pd.datdba
   JOIN pg_inherits pi ON pi.inhrelid = pc.oid
WHERE pd.datname = 'migration'
GROUP BY pi.inhparent
ORDER BY sum(pg_total_relation_size(psu.relid)) DESC;

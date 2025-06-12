create extension if not exists pageinspect;

-- average leaf density
WITH index_info AS (
  SELECT 'records_id_idx'::text AS idxname
  UNION ALL
  SELECT 'records_uuid_v4_idx'::text
  UNION ALL
  SELECT 'records_uuid_v7_idx'::text
),
page_counts AS (
  SELECT
    idxname,
    pg_relation_size(idxname) / 8192 AS num_pages  -- number of 8KB pages
  FROM index_info
),
all_pages AS (
  SELECT
    idxname,
    generate_series(1, num_pages - 1) AS blkno
  FROM page_counts
),
page_stats AS (
  SELECT
    idxname,
    (bt_page_stats(idxname, blkno)).*
  FROM all_pages
),
leaf_pages AS (
  SELECT
    idxname,
    100 - (free_size::float / 8192 * 100) AS fill_percent
  FROM page_stats
  WHERE type = 'l'
)
SELECT
  idxname,
  ROUND(AVG(fill_percent)::numeric, 2) AS avg_leaf_fill_percent
FROM leaf_pages
GROUP BY idxname;

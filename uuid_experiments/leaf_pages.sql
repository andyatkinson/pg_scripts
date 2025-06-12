-- number of leaf pages
WITH index_info AS (
  SELECT 'records_id_idx'::text AS idxname
  UNION ALL
  SELECT 'records_uuid_v4_idx'
  UNION ALL
  SELECT 'records_uuid_v7_idx'
),
page_counts AS (
  SELECT
    idxname,
    pg_relation_size(idxname) / 8192 AS num_pages
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
)
SELECT
  idxname,
  COUNT(*) FILTER (WHERE type = 'l') AS leaf_pages,
  COUNT(*) FILTER (WHERE type = 'd') AS internal_pages
FROM page_stats
GROUP BY idxname
ORDER BY idxname;

--        idxname       | leaf_pages | internal_pages
-- ---------------------+------------+----------------
--  records_id_idx      |      27323 |              0
--  records_uuid_v4_idx |      38315 |              0
--  records_uuid_v7_idx |      38315 |              0


-- AFTER updates
--  idxname       | leaf_pages | internal_pages
-- ---------------------+------------+----------------
--  records_id_idx      |      27589 |              0
--  records_uuid_v4_idx |      48093 |              0
--  records_uuid_v7_idx |      42146 |              0
-- (3 rows)

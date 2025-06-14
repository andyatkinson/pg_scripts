-- Sudden drop in cache_hit_ratio = buffer evictions, possibly caused by vacuum or query pressure.
SELECT
    now(),
    blks_read,
    blks_hit,
    (blks_hit::float / NULLIF (blks_hit + blks_read, 0)) AS cache_hit_ratio
FROM
    pg_stat_database
WHERE
    datname = current_database();

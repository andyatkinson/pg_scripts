WITH table_scans AS (
    SELECT
        relid,
        tables.idx_scan + tables.seq_scan AS all_scans,
        (tables.n_tup_ins + tables.n_tup_upd + tables.n_tup_del) AS writes,
        pg_relation_size(relid) AS table_size
    FROM
        pg_stat_user_tables AS tables
),
indexes AS (
    SELECT
        idx_stat.relid,
        idx_stat.indexrelid,
        idx_stat.schemaname,
        idx_stat.relname AS tablename,
        idx_stat.indexrelname AS indexname,
        idx_stat.idx_scan,
        pg_relation_size(idx_stat.indexrelid) AS index_bytes,
        indexdef ~* 'USING btree' AS idx_is_btree
    FROM
        pg_stat_user_indexes AS idx_stat
        JOIN pg_index USING (indexrelid)
        JOIN pg_indexes AS indexes ON idx_stat.schemaname = indexes.schemaname
            AND idx_stat.relname = indexes.tablename
            AND idx_stat.indexrelname = indexes.indexname
    WHERE
        pg_index.indisunique = FALSE
),
index_ratios AS (
    SELECT
        schemaname,
        tablename,
        indexname,
        idx_scan,
        all_scans,
        round((
            CASE WHEN all_scans = 0 THEN
                0.0::numeric
            ELSE
                idx_scan::numeric / all_scans * 100
            END), 2) AS index_scan_pct,
        writes,
        round((
            CASE WHEN writes = 0 THEN
                idx_scan::numeric
            ELSE
                idx_scan::numeric / writes
            END), 2) AS scans_per_write,
        pg_size_pretty(index_bytes) AS index_size,
        pg_size_pretty(table_size) AS table_size,
        idx_is_btree,
        index_bytes
    FROM
        indexes
        JOIN table_scans USING (relid)
),
index_groups AS (
    SELECT
        'Never Used Indexes' AS reason,
        *,
        1 AS grp
    FROM
        index_ratios
    WHERE
        idx_scan = 0
        AND idx_is_btree
)
SELECT
    reason,
    schemaname,
    tablename,
    indexname,
    index_scan_pct,
    scans_per_write,
    index_size,
    table_size
FROM
    index_groups;

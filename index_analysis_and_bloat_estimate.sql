-- http://www.databasesoup.com/2014/05/new-finding-unused-indexes-query.html
-- I use this for bloat estimate on indexes as well
WITH btree_index_atts AS (
    SELECT nspname, relname, reltuples, relpages, indrelid, relam,
        regexp_split_to_table(indkey::text, ' ')::smallint AS attnum,
        indexrelid as index_oid
    FROM pg_index
    JOIN pg_class ON pg_class.oid=pg_index.indexrelid
    JOIN pg_namespace ON pg_namespace.oid = pg_class.relnamespace
    JOIN pg_am ON pg_class.relam = pg_am.oid
    WHERE pg_am.amname = 'btree'
    ),
index_item_sizes AS (
    SELECT
    i.nspname, i.relname, i.reltuples, i.relpages, i.relam,
    s.starelid, a.attrelid AS table_oid, index_oid,
    current_setting('block_size')::numeric AS bs,
    /* MAXALIGN: 4 on 32bits, 8 on 64bits (and mingw32 ?) */
    CASE
        WHEN version() ~ 'mingw32' OR version() ~ '64-bit' THEN 8
        ELSE 4
    END AS maxalign,
    24 AS pagehdr,
    /* per tuple header: add index_attribute_bm if some cols are null-able */
    CASE WHEN max(coalesce(s.stanullfrac,0)) = 0
        THEN 2
        ELSE 6
    END AS index_tuple_hdr,
    /* data len: we remove null values save space using it fractionnal part from stats */
    sum( (1-coalesce(s.stanullfrac, 0)) * coalesce(s.stawidth, 2048) ) AS nulldatawidth
    FROM pg_attribute AS a
    JOIN pg_stats pgs
    JOIN btree_index_atts AS i ON i.indrelid = a.attrelid AND a.attnum = i.attnum
    WHERE a.attnum > 0
    AND pgs.schemaname = 'public'
    GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9
),
index_aligned AS (
    SELECT maxalign, bs, nspname, relname AS index_name, reltuples,
        relpages, relam, table_oid, index_oid,
      ( 2 +
          maxalign - CASE /* Add padding to the index tuple header to align on MAXALIGN */
            WHEN index_tuple_hdr%maxalign = 0 THEN maxalign
            ELSE index_tuple_hdr%maxalign
          END
        + nulldatawidth + maxalign - CASE /* Add padding to the data to align on MAXALIGN */
            WHEN nulldatawidth::integer%maxalign = 0 THEN maxalign
            ELSE nulldatawidth::integer%maxalign
          END
      )::numeric AS nulldatahdrwidth, pagehdr
    FROM index_item_sizes AS s1
),
otta_calc AS (
  SELECT bs, nspname, table_oid, index_oid, index_name, relpages, coalesce(
    ceil((reltuples*(4+nulldatahdrwidth))/(bs-pagehdr::float)) +
      CASE WHEN am.amname IN ('hash','btree') THEN 1 ELSE 0 END , 0 -- btree and hash have a metadata reserved block
    ) AS otta
  FROM index_aligned AS s2
    LEFT JOIN pg_am am ON s2.relam = am.oid
),
raw_bloat AS (
    SELECT current_database() as dbname, nspname, c.relname AS table_name, index_name,
        bs*(sub.relpages)::bigint AS totalbytes,
        CASE
            WHEN sub.relpages <= otta THEN 0
            ELSE bs*(sub.relpages-otta)::bigint END
            AS wastedbytes,
        CASE
            WHEN sub.relpages <= otta
            THEN 0 ELSE bs*(sub.relpages-otta)::bigint * 100 / (bs*(sub.relpages)::bigint) END
            AS realbloat,
        pg_relation_size(sub.table_oid) as table_bytes,
        stat.idx_scan as index_scans
    FROM otta_calc AS sub
    JOIN pg_class AS c ON c.oid=sub.table_oid
    JOIN pg_stat_user_indexes AS stat ON sub.index_oid = stat.indexrelid
)
SELECT dbname as database_name, nspname as schema_name, table_name, index_name,
        round(realbloat, 1) as bloat_pct,
        wastedbytes as bloat_bytes, pg_size_pretty(wastedbytes::bigint) as bloat_size,
        totalbytes as index_bytes, pg_size_pretty(totalbytes::bigint) as index_size,
        table_bytes, pg_size_pretty(table_bytes) as table_size,
        index_scans
FROM raw_bloat
-- Filter it down a bit this way:
--WHERE ( realbloat > 50 and wastedbytes > 50000000 )
ORDER BY wastedbytes DESC
LIMIT 10; -- Remove this limit if wanting more rows

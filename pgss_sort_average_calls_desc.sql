-- \a unaligned format
-- Nicer separators:
-- \pset fieldsep ' | '
-- \x on
--
-- \! clear
SELECT
    right(query, 200), -- or "query" -- mostly interested in the annotation that's appended on end (or switch to left() if prepended)
    calls,
    rows,
    rows::numeric / NULLIF(calls, 0) AS avg_rows_per_call
FROM
    pg_stat_statements
WHERE
    calls > 0
ORDER BY
    avg_rows_per_call DESC
LIMIT 5;

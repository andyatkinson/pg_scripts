-- Credit: https://www.reddit.com/r/PostgreSQL/comments/xq7334/comment/iq8ln9o/
SELECT
    sequencename,
    max_value,
    last_value,
    (max_value - last_value) AS remaining,
    ((max_value - last_value) * 100.0 / max_value) AS pct_free
FROM
    pg_sequences
ORDER BY
    pct_free ASC;

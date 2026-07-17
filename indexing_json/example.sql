CREATE TABLE stripe_events (
    data jsonb NOT NULL
);

-- Used ChatGPT for these fields
INSERT INTO stripe_events (data)
SELECT
    jsonb_build_object(
        'customer_id', (1000 + gs),
        'event_type', CASE WHEN gs % 2 = 0 THEN 'payment.succeeded' ELSE 'payment.failed' END,
        'amount', (random() * 100)::int,
        'currency', 'usd',
        'timestamp', NOW() - (gs || ' days')::interval
    )
FROM
    GENERATE_SERIES(1, 100000) AS gs;

\timing

-- Takes about 30ms locally
SELECT *
FROM stripe_events
WHERE data ->> 'customer_id' = '1010';

-- postgres=# EXPLAIN (ANALYZE, BUFFERS) SELECT *
-- FROM stripe_events
-- WHERE data ->> 'customer_id' = '1010';
--                                                   QUERY PLAN
-- ---------------------------------------------------------------------------------------------------------------
--  Seq Scan on stripe_events  (cost=0.00..3929.00 rows=500 width=161) (actual time=0.027..30.321 rows=1 loops=1)
--    Filter: ((data ->> 'customer_id'::text) = '1010'::text)
--    Rows Removed by Filter: 99999
--    Buffers: shared hit=2429
--  Planning Time: 0.066 ms
--  Execution Time: 30.341 ms
-- (6 rows)


-- Add index
CREATE INDEX idx_customer_id ON stripe_events ((data ->> 'customer_id'));

-- Now it's an index scan on idx_customer_id and runs in sub-1ms!

-- postgres=# EXPLAIN (ANALYZE, BUFFERS) SELECT *
-- FROM stripe_events
-- WHERE data ->> 'customer_id' = '1010';
--                                                            QUERY PLAN
-- ---------------------------------------------------------------------------------------------------------------------------------
--  Index Scan using idx_customer_id on stripe_events  (cost=0.29..8.31 rows=1 width=161) (actual time=0.057..0.059 rows=1 loops=1)
--    Index Cond: ((data ->> 'customer_id'::text) = '1010'::text)
--    Buffers: shared hit=3
--  Planning Time: 0.092 ms
--  Execution Time: 0.077 ms
-- (5 rows)
--
-- Time: 0.537 ms

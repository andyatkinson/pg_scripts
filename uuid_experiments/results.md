## Results

Between uuid v1 and v7, the execution time of this query was similar, all the buffers were warmed using pg_prewarm,
however we can see for uuid v1 there are MANY more buffers accessed (hits), while reads were about the same.

v1: shared hit=303389 read=38326
v7: shared hit=26 read=38318


```sql
pg18> EXPLAIN (BUFFERS, ANALYZE, TIMING OFF) SELECT COUNT(uuid_v1) FROM records;
                                                                           QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=257280.98..257280.99 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=303389 read=38326
   ->  Gather  (cost=257280.76..257280.97 rows=2 width=8) (actual rows=3.00 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         Buffers: shared hit=303389 read=38326
         ->  Partial Aggregate  (cost=256280.76..256280.77 rows=1 width=8) (actual rows=1.00 loops=3)
               Buffers: shared hit=303389 read=38326
               ->  Parallel Index Only Scan using records_uuid_v1_idx on records  (cost=0.43..245846.44 rows=4173728 width=16) (actual rows=3333333.33 loops=3)
                     Heap Fetches: 0
                     Index Searches: 1
                     Buffers: shared hit=303389 read=38326
 Planning Time: 0.120 ms
 Execution Time: 352.314 ms
(14 rows)

Time: 352.935 ms
pg18> EXPLAIN (BUFFERS, ANALYZE, TIMING OFF) SELECT COUNT(uuid_v7) FROM records;
                                                                           QUERY PLAN
----------------------------------------------------------------------------------------------------------------------------------------------------------------
 Finalize Aggregate  (cost=257280.98..257280.99 rows=1 width=8) (actual rows=1.00 loops=1)
   Buffers: shared hit=26 read=38318
   ->  Gather  (cost=257280.76..257280.97 rows=2 width=8) (actual rows=3.00 loops=1)
         Workers Planned: 2
         Workers Launched: 2
         Buffers: shared hit=26 read=38318
         ->  Partial Aggregate  (cost=256280.76..256280.77 rows=1 width=8) (actual rows=1.00 loops=3)
               Buffers: shared hit=26 read=38318
               ->  Parallel Index Only Scan using records_uuid_v7_idx on records  (cost=0.43..245846.44 rows=4173728 width=16) (actual rows=3333333.33 loops=3)
                     Heap Fetches: 0
                     Index Searches: 1
                     Buffers: shared hit=26 read=38318
 Planning Time: 0.100 ms
 Execution Time: 346.883 ms
(14 rows)

Time: 347.307 ms
```

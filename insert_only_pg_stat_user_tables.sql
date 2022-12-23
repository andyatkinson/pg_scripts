-- check number of inserts, updates, deletes for a table
SELECT
  relname,
  n_tup_ins,
  n_tup_upd,
  n_tup_del
FROM pg_stat_user_tables
WHERE relname = 'trip_positions';

--     relname     | n_tup_ins | n_tup_upd | n_tup_del
-- ----------------+-----------+-----------+-----------
--  trip_positions |      4817 |         0 |         0
-- (1 row)

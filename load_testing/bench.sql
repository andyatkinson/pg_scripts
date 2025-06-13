\set id random(1,1000000)
\set modval random(1,100)

-- BEGIN;
-- INSERT INTO pgxact_burner (payload) VALUES ('txn_' || :id);
-- COMMIT;

BEGIN;

-- Insert a row per transaction
INSERT INTO pgxact_burner (payload) VALUES ('txn_' || :id);

-- Every 100 transactions, delete 10% of the rows (to simulate bloat)
-- This branches randomly, 1 in 100 chance per tx
-- You could also make this deterministic by counting txs externally
\if :modval = 1
  DELETE FROM pgxact_burner
  WHERE id IN (
    SELECT id FROM pgxact_burner
    WHERE id % 10 = 0
    LIMIT 1000
  );
\endif

COMMIT;

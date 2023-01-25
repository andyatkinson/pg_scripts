-- https://www.cybertec-postgresql.com/en/case-insensitive-pattern-matching-in-postgresql/
-- https://database.guide/how-to-return-a-list-of-available-collations-in-postgresql/
SELECT * FROM pg_collation WHERE collname like '%en_US%';

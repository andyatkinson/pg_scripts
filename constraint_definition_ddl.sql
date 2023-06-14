-- https://dba.stackexchange.com/a/298038/272968
SELECT
  connamespace::regnamespace AS schema,
  conrelid::regclass AS table,
  conname AS constraint,
  pg_get_constraintdef(oid) AS definition,
  format ('ALTER TABLE %I.%I ADD CONSTRAINT %I %s;', connamespace::regnamespace,
   conrelid::regclass,
   conname,
   pg_get_constraintdef(oid) ) 
FROM
  pg_constraint 
WHERE
  conname IN ('fk_rails_e7560abc33');

-- https://stackoverflow.com/a/6945493
SELECT
  s.relname AS seq,
  n.nspname AS sch,
  t.relname AS tab,
  a.attname AS col 
FROM
  pg_class s 
JOIN pg_depend d ON d.objid = s.oid 
AND d.classid = 'pg_class'::regclass 
AND d.refclassid = 'pg_class'::regclass 
JOIN pg_class t ON t.oid = d.refobjid 
JOIN pg_namespace n ON n.oid = t.relnamespace 
JOIN pg_attribute a ON a.attrelid = t.oid 
AND a.attnum = d.refobjsubid 
WHERE
  s.relkind = 'S' 
  AND d.deptype = 'a';

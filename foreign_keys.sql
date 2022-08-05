-- https://stackoverflow.com/a/73164028/126688
SELECT conrelid::regclass AS table_name,
       conname AS foreign_key,
       pg_get_constraintdef(oid)
FROM   pg_constraint
WHERE  contype = 'f'
AND    connamespace = 'public'::regnamespace
ORDER  BY conrelid::regclass::text, contype DESC;

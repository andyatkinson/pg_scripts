-- https://stackoverflow.com/questions/343138/retrieving-comments-from-a-postgresql-db

select
  c.table_schema,
  st.relname as TableName,
  c.column_name,
  pgd.description
from pg_catalog.pg_statio_all_tables as st
inner join information_schema.columns c
on c.table_schema = st.schemaname
and c.table_name = st.relname
left join pg_catalog.pg_description pgd
on pgd.objoid=st.relid
and pgd.objsubid=c.ordinal_position
where st.relname = 'YourTableName';


-- https://stackoverflow.com/a/4946306
SELECT
  c.table_schema,
  c.table_name,
  c.column_name,
  pgd.description
FROM
  pg_catalog.pg_statio_all_tables AS st
INNER JOIN
  pg_catalog.pg_description pgd
  ON ( pgd.objoid = st.relid )
INNER JOIN
  information_schema.columns c
  ON ( pgd.objsubid = c.ordinal_position
  AND c.table_schema = st.schemaname
  AND c.table_name = st.relname );

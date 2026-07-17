-- MERGE in Postgres 15

create table people (id int, name text);
create table employees (id int, name text);

insert into people (id, name) VALUES (1, 'Andy');

MERGE INTO employees e
USING people p
ON e.id = p.id
WHEN MATCHED THEN
    UPDATE SET name = p.name
WHEN NOT MATCHED THEN
    INSERT (id, name)
    VALUES (p.id, p.name)
;
-- RETURNING *; 

--  id | name | id | name
-- ----+------+----+------
--   1 | Andy |  1 | Andy
-- (1 row)

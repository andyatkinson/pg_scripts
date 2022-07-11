
-- https://www.crunchydata.com/postgres-tips
-- https://www.citusdata.com/blog/2018/03/14/fun-with-sql-generate-sql/
--
SELECT * FROM generate_series(now() - '1 month'::interval, now(), '1 day');


SELECT * FROM generate_series(1, 5);

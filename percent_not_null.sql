-- fieldname, field like user_id
-- tablename, table like posts (blog posts)
-- https://stackoverflow.com/a/3338509/126688
SELECT
   count(1) as TotalAll,
   count(<fieldname>) as TotalNotNull,
   count(1) - count(<fieldname>) as TotalNull,
   100.0 * count(<fieldname>) / count(1) as PercentNotNull
FROM
   <tablename>;


-- results like:
-- totalall	totalnotnull	totalnull	percentnotnull
-- 3866186202	209948393	3656237809	5.4303745870127132

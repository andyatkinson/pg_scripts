-- Count the statements
SELECT sum(calls) AS total_statements_executed
FROM pg_stat_statements;

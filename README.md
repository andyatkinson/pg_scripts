# PG Scripts

SQL scripts for PostgreSQL to help with maintenance, analysis, and other "Application DBA" concerns.

These are copied from elsewhere on the Internet and the original source will be credited.

## Scripts

### Table stats

`table_stats.sql` - [pg_stats docs](https://www.postgresql.org/docs/9.3/view-pg-stats.html) get statistics on the rows in the table PG collects, such as the most common values, and the most common frequencies. I use this to see if there are any values that occur most of the time, and compare that with what is indexed and what is queried. Indexes are best when they are highly selective.

## Links

* [Deep dive into postgres stats: pg_stat_all_tables](https://dataegret.com/2017/04/deep-dive-into-postgres-stats-pg_stat_all_tables/)
* [Flame explain](https://flame-explain.com/visualize/input)
* [pg_squeeze](https://github.com/cybertec-postgresql/pg_squeeze)
* [Reduce disk bloat in PostgreSQL](https://www.redpill-linpro.com/sysadvent/2017/12/08/pg_repack.html)
* [Annotated.conf](https://github.com/jberkus/annotated.conf)
* [Postgres Index stats and Query Optimization](https://sgerogia.github.io/Postgres-Index-And-Queries/)
* [Some SQL Tricks of an Application DBA](https://hakibenita.com/sql-tricks-application-dba)
* [Lessons Learned From 5 Years of Scaling PostgreSQL](https://onesignal.com/blog/lessons-learned-from-5-years-of-scaling-postgresql/)

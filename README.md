# PG Scripts

Queries and scripts for PostgreSQL to help with maintenance, analysis, and other "Application DBA" concerns.

These are copied from elsewhere on the Internet and the original source will be credited as a line comment in the file.

I also am adding interesting links I've used over time to the bottom of this file.

## psql

* `\dn` - list schemas

## Names and Descriptions

Calling out some specifc ways I've used these.

* `list_comments.sql` - List fields that have been commented, and their comment content

* `index_analysis_and_bloat_estimate.sql` - I use this to check index bloat estimate and index scans

* `find_unused_indexes.sql` - I use this to find unused indexes that can likely be removed

* `relation_size.sql` - I use this to check that an index build completed fully and is not a zero bytes index

* `create_index_create_statement.sql` - get the `CREATE INDEX` statement from an existing index. I use this when an index build fails but the same index exists in another environment (e.g. pre-prod) and I want to manually apply the same statement

* `table_stats.sql` - [pg_stats docs](https://www.postgresql.org/docs/9.3/view-pg-stats.html) get statistics on the rows in the table PG collects, such as the most common values, and the most common frequencies. I use this to see if there are any values that occur most of the time, and compare that with what is indexed and what is queried. Indexes are best when they are highly selective.

* `detect_transaction_id_wraparound.sql` - Detect transaction ID wraparound

* `percent_not_null`: Can be used to determine proportion of total rows where a particular field is null. Help determine selectivity of field and whether partial index is a good fit.

* `psql_csv_output.csv` - From `psql`, format a query output as CSV and send it to a file

* `view_extensions.sql` - View installed extensions names and versions

* `list_indexes.sql` - List the indexes for a table

* `list_partitioned_tables.sql` (`\dP`) - Get all ordinary tables, including root partitioned tables, but excluding all non-root partitioned tables.

* `list_schemata.sql` - List the schemas

* Cancel and terminate backend process IDs (PIDs)

* `waiting_queries.sql` - View waiting queries

* `multiple_row_updates.sql` - How to update column values for multiple rows in a single UPDATE statement

## Links

* [Deep dive into postgres stats: pg_stat_all_tables](https://dataegret.com/2017/04/deep-dive-into-postgres-stats-pg_stat_all_tables/)
* [Flame explain](https://flame-explain.com/visualize/input)
* [pg_squeeze](https://github.com/cybertec-postgresql/pg_squeeze)
* [Reduce disk bloat in PostgreSQL](https://www.redpill-linpro.com/sysadvent/2017/12/08/pg_repack.html)
* [Annotated.conf](https://github.com/jberkus/annotated.conf)
* [Postgres Index stats and Query Optimization](https://sgerogia.github.io/Postgres-Index-And-Queries/)
* [Some SQL Tricks of an Application DBA](https://hakibenita.com/sql-tricks-application-dba)
* [Lessons Learned From 5 Years of Scaling PostgreSQL](https://onesignal.com/blog/lessons-learned-from-5-years-of-scaling-postgresql/)
* [Understanding PostgreSQL Query Performance](https://pgdash.io/blog/understanding-postgres-query-performance.html)

## Write rate

* From [Crunchy Data Postgres Tips](https://www.crunchydata.com/postgres-tips), for manually building indexes, can temporarily increase the maintenance work memory, e.g.

`SET maintenance_work_mem = '1GB';`

## Other Misc. Tips

* Log lock waits. I also wonder if there could be a feature like logging slow statements, but logging only long lock waits as opposed to logging all lock waits if this is too noisy.

`ALTER DATABASE postgres SET log_lock_waits = 'on'`

* Continually run a query with `\watch`
* Border style, can also specify it when running a command via `-c`: `psql -P linestyle=unicode -P border=2 -c "select 1 as col"`


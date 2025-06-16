# Load testing

1. buffer cache eviction
1. buffer locks, page access waits (query and vacuum contention)
1. hot chain depth
1. page level locks
1. pg_stat_io info that can be sampled
1. tuple visibility pruning
1. SLRU status


## Try:
1. Manual `VACUUM FREEZE` on hot tables


## pgbench simulation
Tmux, two panes, pgbench installed, benchdb created, single table `pgxact_burner`

```sql
createdb benchdb;

CREATE TABLE pgxact_burner (
    id SERIAL PRIMARY KEY,
    payload TEXT
);

INSERT INTO pgxact_burner (payload)
SELECT repeat('x', 100)
FROM generate_series(1, 10000);

-- delete, then insert again, generate bloat
DELETE FROM pgxact_burner;
```


## Running tests
Prereq:
- Set PGDATA
```sh
export PGDATA="$(psql -U postgres \
  -Atc 'SHOW data_directory')"
echo "Set PGDATA: $PGDATA"
```
- Enable pg_stat_statements in DBNAME
```sh
psql -d $DBNAME
create extension if not exists pg_stat_statements;
```
- Set values for DBNAME (defaults to benchdb)

1. Clear out logs
```sh
rm pgbench_monitor*.log
```

2. Run events capture
This runs two loops, one collecting information, one running vacuums
Tmux pane 1:
(cntrl-b x to kill-pane when done)
`sh logging_events.sh`

Can tail this using `tail -f <logfile>`

3. Generate system load using pgbench
Tmux pane 2:
Generate load with pgbench:
Run for 60 seconds, 20 clients (spikes CPU)
`pgbench -f bench.sql -T 60 -c 20 -j 2 benchdb`

NOTE: this manually runs VACUUM periodically in a second loop. This could be disabled though to focus only on when Autovacuum is triggered and runs VACUUM.

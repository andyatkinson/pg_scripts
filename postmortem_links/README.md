# Postmortem Links

# Anti-wraparound vacuum, DDL lock conflict, blocking queries
Shared lock application queries got blocked on an exclusive lock.

They discovered that VACUUM would run as an anti-wraparound (aggressive) type, and a normally
innocuous `DROP TRIGGER IF EXISTS` would require a conflicting exclusive lock, get blocked, then block shared lock
acquisition requests from regular shared lock queries.

> During the event, one of the shard databases had all queries on our primary table blocked by a three-way interaction between the data path queries that wanted shared locks, a "transaction wraparound" autovacuum that held a shared lock and ran for several hours, and an errant query that wanted an exclusive table lock.

- <https://www.tritondatacenter.com/blog/manta-postmortem-7-27-2015>

# High water mark VACUUM TRUNCATE locking issue, blocking queries
- Large DELETE statement, COPY FROM STDIN, 16 HASH partitions
- SELECTs would time out
- TRUNCATE portion of Autovacuum
- Queries wait on lock acquisition from exclusive lock for TRUNCATE portion of VACUUM
- They added a logging script of the high water mark

- <https://shaneborden.com/2025/06/06/understanding-high-water-mark-locking-issues-in-postgresql-vacuums/>

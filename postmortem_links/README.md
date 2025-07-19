# Postmortem Links

# Triton: Anti-wraparound vacuum, DDL lock conflict, blocking queries
Shared lock application queries got blocked on an exclusive lock.

They discovered that VACUUM would run as an anti-wraparound (aggressive) type, and a normally
innocuous `DROP TRIGGER IF EXISTS` would require a conflicting exclusive lock, get blocked, then block shared lock
acquisition requests from regular shared lock queries.

> During the event, one of the shard databases had all queries on our primary table blocked by a three-way interaction between the data path queries that wanted shared locks, a "transaction wraparound" autovacuum that held a shared lock and ran for several hours, and an errant query that wanted an exclusive table lock.
<https://www.tritondatacenter.com/blog/manta-postmortem-7-27-2015>

# Shane: High water mark VACUUM TRUNCATE locking issue, blocking queries
- Large DELETE statement, COPY FROM STDIN, 16 HASH partitions
- SELECTs would time out
- TRUNCATE portion of Autovacuum
- Queries wait on lock acquisition from exclusive lock for TRUNCATE portion of VACUUM
- They added a logging script of the high water mark
<https://shaneborden.com/2025/06/06/understanding-high-water-mark-locking-issues-in-postgresql-vacuums/>

# GitLab: Data Loss
- Use of pg_basebackup intended for a replica, performed on primary
<https://about.gitlab.com/blog/postmortem-of-database-outage-of-january-31/>

# GitLab: Subtrans SLRU overflow
> There are 32 (NUM_SUBTRANS_BUFFERS) pages, which means up to 65K transaction IDs can be stored in memory. Nikolay demonstrated that in a busy system, it took about 18 seconds to fill up all 65K entries. Then performance dropped off a cliff, making the database replicas unusable.
<https://about.gitlab.com/blog/why-we-spent-the-last-month-eliminating-postgresql-subtransactions/>

# Hairy incident: Ardent Perf / Jeremy
- Bad query plan, changed BitmapOr to BitmapAnd with a big IN list
<https://ardentperf.com/2022/02/10/a-hairy-postgresql-incident/>

# Figma: Long running query
- Anti-wraparound Vacuum
- Bad plan (mis-estimate, 20 million not 3), table scan, write to temp buffers
- Planner: "Inner Unique: true"
- Under-estimated selectivity of inner-most subquery
<https://www.figma.com/blog/post-mortem-service-disruption-on-january-21-22-2020/>

# PgBackups: Lock conflict
- Lock conflict, exclusive lock for PgBackups (pg_dump -j) held,
exclusive lock used for DDL migration (add column, NOT NULL constraint, default 0)
<https://gist.github.com/dwbutler/1034446c1aba231ca8d8639d3be78c6b>

# Metronome: Root Cause Analysis: PostgreSQL MultiXact member exhaustion incidents (May 2025)
- crossed a previously unknown and difficult to monitor global limit on MultiXact members
<https://metronome.com/blog/root-cause-analysis-postgresql-multixact-member-exhaustion-incidents-may-2025?utm_campaign=rca-may-2025&utm_medium=social&utm_source=linkedin&utm_content=>

# Postgres “almost” Outage Postmortem: The Hidden Dangers of Replication Slots and Autovacuum
- Inactive logical replication slots
- Holding WAL files forever
<https://dev.to/sasikumart/postgres-almost-outage-postmortem-the-hidden-dangers-of-replication-slots-and-autovacuum-2nem>

# Sentry: Transaction ID Wraparound
<https://blog.sentry.io/transaction-id-wraparound-in-postgres/>

# Mailchimp: Transaction ID Wraparound
<https://mailchimp.com/what-we-learned-from-the-recent-mandrill-outage/>

# go-yubi.com: Unveiling the Mysteries of Production PostgreSQL Storage Issues: A Root Cause Analysis
- a surge in CPU utilization, jeopardizing system stability, chiefly stemming from heightened read operations on TOAST data.
<https://www.go-yubi.com/blog/unveiling-the-mysteries-of-production-postgresql-storage-issues-a-root-cause-analysis/>

# The Life of a Bug: From Customer Escalation to PostgreSQL commit
- <https://www.enterprisedb.com/blog/life-bug-customer-escalation-postgresql-commit>

## Slides
- Amazing! Keiko Oda: Exploring Postgres VACUUM with the VACUUM Simulator <https://speakerdeck.com/keiko713/exploring-postgres-vacuum-with-the-vacuum-simulator>

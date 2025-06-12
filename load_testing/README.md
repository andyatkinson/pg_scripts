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

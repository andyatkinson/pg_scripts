select pid, wait_event_type, wait_event, left(query, 60) as query, backend_start, query_start, (current_timestamp - query_start) as ago from pg_stat_activity where datname='rideshare_development';

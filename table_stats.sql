SELECT attname, n_distinct, most_common_vals, most_common_freqs FROM pg_stats WHERE tablename = 'table';

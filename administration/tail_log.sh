#!/bin/bash

echo "Running as $(whoami)"

echo "Find PostgreSQL data directory"
pgdata="$(psql $DATABASE_URL -c 'SHOW data_directory' --tuples-only | sed 's/^[ \t]*//')"

echo "Find current log file"
pglog="$(psql -U postgres -c 'SELECT pg_current_logfile()' --tuples-only | awk '{print $1}')"

full_path="$pgdata/$pglog"
echo "full_path: $full_path"

tail -f "$full_path"

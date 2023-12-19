#!/bin/bash
#
# Use default log_line_prefix (may need to undo changes)
#
pgdata="$(psql "$DATABASE_URL" -c 'SHOW data_directory' --tuples-only | sed 's/^[ \t]*//')"

pglog="$(psql -U postgres -c 'SELECT pg_current_logfile()' --tuples-only | awk '{print $1}')"

echo "Found log: $pgdata/$pglog"
echo "Running pgbadger..."
pgbadger "$pgdata/$pglog"
open out.html

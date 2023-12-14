#!/bin/bash

pgdata="$(psql "$DATABASE_URL" -c 'SHOW data_directory' --tuples-only | sed 's/^[ \t]*//')"
echo "SHOW data_directory: $pgdata"

pglog="$(psql -U postgres -c 'SELECT pg_current_logfile()' --tuples-only | awk '{print $1}')"
echo "SELECT pg_current_logfile(): $pglog"

tail -f "$pgdata/$pglog"

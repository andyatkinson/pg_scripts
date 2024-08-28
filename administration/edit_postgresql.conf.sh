#
# Adapted from: https://github.com/andyatkinson/rideshare/issues/206
# GitHub: @knightq

#!/bin/bash

export DB_URL='postgres://postgres:@localhost:5432/postgres'

pgdata="$(psql "$DB_URL" -c 'SHOW data_directory' --tuples-only | sed 's/^[ \t]*//')"

${EDITOR:-vim} "$pgdata/postgresql.conf"

# expects $PGDATA to be set
# export PGDATA="$(psql -U postgres \
#   -c 'SHOW data_directory' \
#   --tuples-only | sed 's/^[ \t]*//')"
# echo "Set PGDATA: $PGDATA"
du -sh $PGDATA/pg_xact/
# ls -lh $PGDATA/pg_xact/

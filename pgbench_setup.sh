# examples:
# https://medium.com/@samokhvalov/how-partial-indexes-affect-update-performance-in-postgres-d05e0052abc
echo "\set owner_id random(1, 1 * 1000000)" > selects.bench
echo "select from asset where owner_id = :owner_id and price is not null;" >> selects.bench
pgbench -n -T 30 -j 4 -c 12 -M prepared -f selects.bench -r test


echo "\set id random(1, 1 * 600000)" > updates.bench
echo "update asset set price = price + 10 where id = :id;" >> updates.bench
psql test -c 'vacuum full analyze asset;' && \
  psql test -c 'select pg_stat_reset();' >> /dev/null && \
  pgbench -n -T 30 -j 4 -c 12 -M prepared -r test -f updates.bench

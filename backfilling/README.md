### Backfilling examples


Invoke like this:

```sh
psql --dbname experiments \
  -f 0-populate-riders.sql \
  -f 1-create-schema.sql  \
  -f 2-create-table.sql \
  -f 3-insert-into-select-from.sql
```

# UUID Experiments

- UUID v7 extension
<https://pgxn.org/dist/pg_uuidv7/>
- enable `pg_prewarm`
- enable `pageinspect`

```sh
cd # into pg_uuidv7 directory
```

Needs libpq, make sure it's using Postgres.app version.

```sh
make
sudo make install PG_CONFIG=/Applications/Postgres.app/Contents/Versions/16/bin/pg_config
create extension pg_uuidv7;
```

- Reproduce results here:
<https://www.cybertec-postgresql.com/en/unexpected-downsides-of-uuid-keys-in-postgresql/>

## Pageinspect
```sql
create extension if not exists pageinspect;
```


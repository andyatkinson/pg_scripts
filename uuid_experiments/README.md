# UUID Experiments

## PgPrewarm and Pageinspect
```sql
create extension if not exists pg_prewarm;
create extension if not exists pageinspect;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## All Postgres versions
- enable `pageinspect` extension in target DB

## Postgres versions
- Postgres 18: Use built-in UUID v7 function
- Postgres Pre-18: Use UUID v7 extension to generate values
<https://pgxn.org/dist/pg_uuidv7/>

## Extension
I run Postgres 16 on macOS using [Postgres.app](https://postgresapp.com).
```sh
cd # into pg_uuidv7 directory
make
sudo make install PG_CONFIG=/Applications/Postgres.app/Contents/Versions/16/bin/pg_config
```

Then from psql, in the target database:
```sql
create extension pg_uuidv7;
```

- Reproduce results here:
<https://www.cybertec-postgresql.com/en/unexpected-downsides-of-uuid-keys-in-postgresql/>

For the page density comparison, see `page_density.sql`

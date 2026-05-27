# UUID Experiments

This looks at using the `uuid` data type in Postgres, and storing values with [layouts](https://www.rfc-editor.org/rfc/rfc9562.html#name-uuid-layouts) of v1, v4, and v7.

## Postgres Extensions PgPrewarm and Pageinspect
Enable these extensions:
```sql
create extension if not exists pg_prewarm;
create extension if not exists pageinspect;
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

## Postgres and UUID versions
- Postgres 18: Used built-in UUID v7 generation function
- Postgres Pre-18: (Tested on 16) Used UUID v7 extension to generate values
<https://pgxn.org/dist/pg_uuidv7/>
- Generated v4 using native function
- Generated v1 values using uuid-ossp

## Adding Postgres Extensions on macOS
For Postgres 16 on macOS I used [Postgres.app](https://postgresapp.com).

Here's how I added the pg_uuidv7 extension.
```sh
cd # into pg_uuidv7 directory
make
sudo make install PG_CONFIG=/Applications/Postgres.app/Contents/Versions/16/bin/pg_config
```

Then from psql in the target database:
```sql
create extension pg_uuidv7;
```

- Reproduce results from this post:
<https://www.cybertec-postgresql.com/en/unexpected-downsides-of-uuid-keys-in-postgresql/>

For the page density comparison, see `page_density.sql`

Explore files:
- `create_tables.sql`
- `create_indexes.sql`

View results in `results.md`

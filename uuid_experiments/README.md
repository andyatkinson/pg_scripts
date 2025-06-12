# UUID Experiments

- UUID v7 extension
<https://pgxn.org/dist/pg_uuidv7/>

- enable pg_prewarm

```sh
# needs libpq, make sure it's using Postgres.app version
make
make install
create extension pg_uuidv7;
```

- Reproduce results here:
<https://www.cybertec-postgresql.com/en/unexpected-downsides-of-uuid-keys-in-postgresql/>

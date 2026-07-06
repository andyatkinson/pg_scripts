#!/usr/bin/env bash
set -eu

# Purpose: Following replica promotion we have a lot of tables to remove.
# To make the process safer:
# 1. First rename all tables by prepending "__unused__" to their name.
# 1a. The "bulk rename" can be reversed, see the commented out section below.
#
# Once bulk renamed, manually run DROP TABLE commands on __unused__* tables. This part
# is not scripted.
#
# If a table should NOT be dropped, reverse the rename.
#
# To use: Add all tables to NOT rename to the DO_NOT_RENAME_THESE_TABLES variable,
# all other tables (the majority) will be bulk-renamed with the prefix __unused__
#
# Tested on Docker Postgres 18
#
# docker pull postgres:18
# docker run --name pg18 --env POSTGRES_USER=postgres --env POSTGRES_PASSWORD=postgres --detach postgres:18
# docker exec -it pg18 psql -U postgres
# create database test;
# \c test
# create table customers (id int);
# create table orders (id int);
# create table table1 (id int);
# create table table2 (id int);
#

DB_NAME="test"
PG_USER="postgres"
PG_PASSWORD="postgres"
DO_NOT_RENAME_THESE_TABLES="('table1','table2')" # Use SQL IN format, e.g. ('table1','table2')

echo "Seeing if we can connect"
docker exec -it -e PGPASSWORD=$PG_PASSWORD -e PGDATABASE=$DB_NAME -e PGUSER=$PG_USER pg18 psql -c "select 'can connect'"

# echo "Performing big rename"
# docker exec -it -e PGPASSWORD=$PG_PASSWORD -e PGDATABASE=$DB_NAME -e PGUSER=$PG_USER pg18 psql -c "
# DO \$\$
# DECLARE
#   t record;
#   new_name text;
# BEGIN
#   FOR t IN
#     SELECT tablename
#     FROM pg_tables
#     WHERE schemaname = 'public'
#     AND tablename NOT IN $DO_NOT_RENAME_THESE_TABLES
#   LOOP
#     new_name := '__unused__' || t.tablename;
#     RAISE NOTICE 'Renaming table % to %', t.tablename, new_name;
#     EXECUTE format(
#       'ALTER TABLE public.%I RENAME TO %I',
#       t.tablename,
#       new_name
#     );
#   END LOOP;
# END \$\$;
# "

#=================
# UNCOMMENT THIS TO UNDO/REVERSE ABOVE
# =================
#
#
# echo "Strip the __unused__ prefix"
# docker exec -it -e PGPASSWORD=$PG_PASSWORD -e PGDATABASE=$DB_NAME -e PGUSER=$PG_USER pg18 psql -c "
# DO \$\$
# DECLARE
#   t record;
#   new_name text;
# BEGIN
#   FOR t IN
#     SELECT tablename
#     FROM pg_tables
#     WHERE schemaname = 'public'
#     AND tablename LIKE '__unused__%'
#   LOOP
#     RAISE NOTICE 'Found table %', t.tablename;
#     new_name := regexp_replace(t.tablename, '^__unused__', '');
#     RAISE NOTICE 'Renaming % -> %', t.tablename, new_name;
#     EXECUTE format(
#       'ALTER TABLE public.%I RENAME TO %I',
#       t.tablename,
#       new_name
#     );
#   END LOOP;
# END \$\$;
# "

echo "Viewing all tables"
docker exec -it -e PGPASSWORD=$PG_PASSWORD -e PGDATABASE=$DB_NAME -e PGUSER=$PG_USER pg18 psql -c "select tablename from pg_tables where schemaname = 'public'"

echo "Do not rename table(s) are not renamed"
docker exec -it -e PGPASSWORD=$PG_PASSWORD -e PGDATABASE=$DB_NAME -e PGUSER=$PG_USER pg18 psql -c "select tablename from pg_tables where schemaname = 'public' AND tablename IN $DO_NOT_RENAME_THESE_TABLES"

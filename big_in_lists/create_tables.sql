-- Create tables for big IN list experimentation
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS authors;

CREATE TABLE IF NOT EXISTS authors (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- 4-byte integer ID
  name TEXT NOT NULL
);

CREATE TABLE IF NOT EXISTS books (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- 4-byte integer ID
  title TEXT NOT NULL,
  author_id INTEGER NOT NULL REFERENCES authors(id)
);

-- Insert authors and books
\timing on
DO $$
DECLARE
    i INTEGER;
    author_id INTEGER;
BEGIN
    -- Insert 50,0000 unique authors
    FOR i IN 1..50000 LOOP
        INSERT INTO authors (name)
        VALUES ('Author ' || i);
    END LOOP;

    -- Insert 1,000,000 unique books
    FOR i IN 1..1000000 LOOP
        author_id := (SELECT FLOOR(RANDOM() * 10000 + 1)::INT); -- Random author between 1 and 10000
        INSERT INTO books (title, author_id)
        VALUES ('Book Title ' || i, author_id);
    END LOOP;
END
$$;

-- Create index
CREATE INDEX IF NOT EXISTS idx_books_author_id ON books (author_id);
CREATE INDEX IF NOT EXISTS idx_books_title ON books (title);

SET enable_seqscan TO off;

-- Get all the author ids
SELECT
    id
FROM
    authors;

-- Simulate an IN clause
-- seq scan on books, rows=100000
-- 50ms
\timing on

-- CTE version simulating a pluck IN clause
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
WITH author_ids AS (
SELECT
    id
FROM
    authors
)
select title from books
where author_id IN (select id from author_ids);


-- LEFT OUTER JOIN
-- This is faster although it's not using the index scan
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT
    books.title
FROM
    books
LEFT OUTER JOIN authors ON authors.id = books.author_id;

-- Needs an index on books (author_id, title)
CREATE INDEX IF NOT EXISTS idx_books_aid_title ON books (author_id, title);

-- Now we get an index only scan using "idx_books_aid_title"

-- What about ANY / SOME
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
WITH author_ids AS (
  SELECT id FROM authors
)
SELECT title
FROM books
WHERE author_id = ANY (
      SELECT id
      FROM author_ids);

EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
WITH author_ids AS (
SELECT
    id
FROM
    authors
)
select title from books
where author_id = SOME(select id from author_ids); -- <- SOME


-- Using ANY with a "<" operator
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
WITH author_ids AS (
SELECT
    id
FROM
    authors
)
select title from books
where author_id < ANY(select id from author_ids where id <= 10); -- <- ANY


-- VALUES clause
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
WITH ids(author_id) AS (
  VALUES(1),(2),(3)
)
SELECT title
FROM books
JOIN ids USING (author_id);


-- Temp table
CREATE TEMP TABLE temp_ids (author_id int);
INSERT INTO temp_ids(author_id) VALUES (1),(2),(3);
CREATE INDEX ON temp_ids(author_id);

SELECT title
FROM books b
JOIN temp_ids t ON t.author_id = b.author_id;


-- subquery version
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT title
FROM books
WHERE author_id IN (
  SELECT id
  FROM (VALUES(1),(2),(3)) AS v(id)
);


-- ANY with an ARRAY
EXPLAIN (ANALYZE, BUFFERS, COSTS OFF)
SELECT title
FROM books
WHERE author_id = ANY (ARRAY[1, 2, 3]);

-- ANY is treated as a single functional expression
-- ANY works better with prepared statements
PREPARE get_books_by_author(int[]) AS
SELECT title
FROM books
WHERE author_id = ANY ($1);

EXECUTE get_books_by_author(ARRAY[1,2,3,4,5]);

CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

andy@[local]:5432 bigin# WITH user_oid AS (
    SELECT
        oid
    FROM
        pg_roles
    WHERE
        rolname = CURRENT_USER
),
db_oid AS (
    SELECT
        oid
    FROM
        pg_database
    WHERE
        datname = current_database())
SELECT
    query
FROM
    pg_stat_statements pgss
    JOIN user_oid ON pgss.userid = user_oid.oid
    JOIN db_oid ON pgss.dbid = db_oid.oid
WHERE
    pgss.query LIKE '%IN \(%';
--                      query
-- ------------------------------------------------
--  WITH author_ids AS (                          +
--  SELECT                                        +
--      id                                        +
--  FROM                                          +
--      authors                                   +
--  )                                             +
--  select title from books                       +
--  where author_id IN (select id from author_ids)

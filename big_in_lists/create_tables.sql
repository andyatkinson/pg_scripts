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

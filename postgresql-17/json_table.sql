CREATE TABLE IF NOT EXISTS books (
    id integer NOT NULL,
    name varchar NOT NULL,
    data jsonb
);

INSERT INTO books (id, name, data)
    VALUES (
      1,
      'High Performance PostgreSQL for Rails',
      jsonb_build_object(
        'publisher', 'Pragmatic Bookshelf; 1st edition (July 23, 2024)',
        'isbn', '979-8888650387',
        'author','Andrew Atkinson'));

SELECT
    isbn,
    publisher,
    author
FROM
    books,
    JSON_TABLE (data, '$' COLUMNS (
        publisher text PATH '$.publisher',
        isbn text PATH '$.isbn',
        author text PATH '$.author'
    )) AS jt;


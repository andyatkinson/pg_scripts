-- Guess column names that are common
-- for when the application uses soft deletes
SELECT
    table_schema,
    table_name,
    column_name,
    data_type
FROM
    information_schema.columns
WHERE
    column_name = 'deleted_at';

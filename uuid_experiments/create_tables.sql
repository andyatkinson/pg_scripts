CREATE TABLE records (
    id int8 NOT NULL,
    uuid_v4 uuid NOT NULL,
    uuid_v7 uuid NOT NULL,
    filler text
);

INSERT INTO records
SELECT
    id,
    gen_random_uuid(),
    uuid_generate_v7(),
    repeat(' ', 100)
FROM
    generate_series(1, 10000000) id;

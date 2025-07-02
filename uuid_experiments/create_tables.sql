CREATE TABLE records (
    id int8 NOT NULL,
    uuid_v4 uuid NOT NULL,
    uuid_v7 uuid NOT NULL,
    filler text
);

-- 10 million inserts
INSERT INTO records
SELECT
    id,
    gen_random_uuid(),
    uuid_generate_v7(),
    repeat(' ', 100)
FROM
    generate_series(1, 10000000) id;

-- 1 million updates
CREATE TEMP TABLE update_ids AS
SELECT id
FROM generate_series(1, 10000000) id
ORDER BY random()
LIMIT 1000000;

-- Perform the updates on uuid_v4 and uuid_v7 columns (and filler text)
UPDATE records
SET
  uuid_v4 = gen_random_uuid(),
  uuid_v7 = uuid_generate_v7(),
  filler = repeat('x', 100)
WHERE id IN (SELECT id FROM update_ids);

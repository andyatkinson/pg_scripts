CREATE SEQUENCE IF NOT EXISTS riders_id_seq;
CREATE TABLE IF NOT EXISTS riders (
  id bigint DEFAULT nextval('riders_id_seq') PRIMARY KEY,
  first_name text
);

TRUNCATE riders;

INSERT INTO riders (first_name)
SELECT md5(random()::text)
FROM generate_series(1,100000);

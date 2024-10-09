--https://www.postgresqltutorial.com/postgresql-random-range/
CREATE OR REPLACE FUNCTION random_between (low int, high int)
    RETURNS int
    AS $$
BEGIN
    RETURN floor(random() * (high - low + 1) + low);
END;
$$
LANGUAGE 'plpgsql'
STRICT;

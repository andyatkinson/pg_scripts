
-- https://pgpedia.info/p/pg_trigger_depth.html
CREATE TABLE foo (id INT, val TEXT);

CREATE OR REPLACE FUNCTION trigger_depth()
 RETURNS TRIGGER
 LANGUAGE plpgsql
AS $$
 DECLARE
   depth INT;
 BEGIN
   depth := pg_trigger_depth();
   RAISE NOTICE 'depth: %', depth;
   IF depth = 1 THEN
      INSERT INTO foo VALUES(-1, 'test');
   END IF;
   RETURN NEW;
 END;
$$;

CREATE TRIGGER foo_ins_trigger
 BEFORE INSERT
 ON foo
 FOR EACH ROW
 EXECUTE FUNCTION trigger_depth();

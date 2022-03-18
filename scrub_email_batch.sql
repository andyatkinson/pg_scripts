--
-- Example procedure to scrub a column
-- With a batch of records at a time
--
-- Resources
-- * https://stackoverflow.com/questions/67091815/how-to-update-a-single-column-in-postgres-in-a-batch-for-55-million-records
-- * https://www.postgresql.org/docs/9.3/functions-string.html
CREATE or replace PROCEDURE scrub_email_batch(_tbl regclass, _col character varying(255))
LANGUAGE plpgsql
AS $$

DECLARE
  batch_size int := 50;
  orig_email character varying(255);
  scrubbed_email character varying(255);
  min_id bigint;
  max_id bigint;
BEGIN

  EXECUTE format('SELECT max(id), min(id) FROM %s', _tbl) INTO max_id, min_id;
  RAISE INFO 'table=% column=% max_id=% min_id=%', _tbl, _col, max_id, min_id;

  FOR j IN min_id..max_id BY batch_size LOOP
    FOR k IN j..j + batch_size LOOP

      -- 1) capture original email
      -- %L with format will use it literally
      EXECUTE format('SELECT %s from %s where id = %s', _col, _tbl, k) INTO orig_email;
      CONTINUE WHEN orig_email IS NULL;
      RAISE INFO 'orig % ', orig_email;

      --
      -- could develop a plpgsql function like scrub_email(%L) here to call
      -- But we will just pass in a static value here 'xyz@example.com'

      -- 2) update emails individually for each in batch_size
      -- quote_literal() supplies the value quoted in the statement
      EXECUTE format('UPDATE %s SET %s = %s WHERE id = %s', _tbl, _col, quote_literal('xyz@example.com'), k);
    END LOOP;

    RAISE INFO 'committing batch from % to % at %', j, j + batch_size, now();
    COMMIT;
  END LOOP; -- batch loop
END;
$$;

--CALL scrub_email_batch('users', 'email');

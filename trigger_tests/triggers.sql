-- https://www.postgresql.org/docs/current/plpgsql-trigger.html

CREATE TABLE employees (
  id integer,
  salary integer default 0,
  updated_at timestamptz
);

CREATE FUNCTION employee_calc() RETURNS trigger AS $employee_calc$
    BEGIN
        -- Check that salary is not null
        IF NEW.salary IS NULL THEN
            RAISE EXCEPTION 'salary cannot be null';
        END IF;
        IF NEW.salary IS NULL THEN
            RAISE EXCEPTION '% cannot have null salary', NEW.id;
        END IF;

        -- Who works for us when they must pay for it?
        IF NEW.salary < 0 THEN
            RAISE EXCEPTION '% cannot have a negative salary', NEW.id;
        END IF;

        NEW.updated_at := current_timestamp;
        RETURN NEW;
    END;
$employee_calc$ LANGUAGE plpgsql;

CREATE TRIGGER employee_calc BEFORE INSERT OR UPDATE ON employees
    FOR EACH ROW EXECUTE FUNCTION employee_calc();

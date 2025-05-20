create table employees (id int, name text, is_admin boolean);

insert into employees (id, name, is_admin) VALUES (1, 'Andy', true);
insert into employees (id, name, is_admin) VALUES (2, 'Jane', false);
insert into employees (id, name, is_admin) VALUES (3, 'Jared', false);

CREATE VIEW non_admins AS
SELECT * FROM employees
WHERE is_admin = false;

SELECT * FROM non_admins;

-- Updatable automatically by INSERT, UPDATE, DELETE

-- With 17, added MERGE support
-- Can be updated with trigger-updatable

CREATE OR REPLACE FUNCTION update_employee()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE employees
    SET is_admin = NEW.is_admin
    WHERE id = OLD.id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_non_admins
INSTEAD OF UPDATE ON non_admins
FOR EACH ROW
EXECUTE FUNCTION update_employee();

UPDATE non_admins SET is_admin = true where id = 2 RETURNING *;

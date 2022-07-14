create database experiments;
-- \c experiments

create table list_items (
  id serial primary key,
  list_id integer,
  position integer
);

-- \d list_items
--                               Table "public.list_items"
-- +----------+---------+-----------+----------+----------------------------------------+
-- |  Column  |  Type   | Collation | Nullable |                Default                 |
-- +----------+---------+-----------+----------+----------------------------------------+
-- | id       | integer |           | not null | nextval('list_items_id_seq'::regclass) |
-- | list_id  | integer |           |          |                                        |
-- | position | integer |           |          |                                        |
-- +----------+---------+-----------+----------+----------------------------------------+
-- Indexes:
--     "list_items_pkey" PRIMARY KEY, btree (id)


-- add some rows
insert into list_items (list_id, position) SELECT 1, generate_series(1, 10, 1);


-- use update ... from syntax
-- https://stackoverflow.com/a/18799497
--
-- another example:
--
-- update users as u set -- postgres FTW
--   email = u2.email,
--   first_name = u2.first_name,
--   last_name = u2.last_name
-- from (values
--   (1, 'hollis@weimann.biz', 'Hollis', 'Connell'),
--   (2, 'robert@duncan.info', 'Robert', 'Duncan')
-- ) as u2(id, email, first_name, last_name)
-- where u2.id = u.id;

update list_items as li set
  id = li2.id,
  position = li2.position

from (values
    (2, 1),
    (1, 2)
) as li2(id, position)
where li2.id = li.id;

-- note that after the statement above, sorting the list items
-- by primary key id ascending order, we see the positions of 2 and 1
-- have swapped now, so row 1 is now in position "2",
-- and row 2 (pk: 2) is now in position "1"

-- [local]:5432 experiments# select * from list_items order by id asc;
-- +----+---------+----------+
-- | id | list_id | position |
-- +----+---------+----------+
-- |  1 |       1 |        2 |
-- |  2 |       1 |        1 |
-- |  3 |       1 |        3 |
-- |  4 |       1 |        4 |
-- |  5 |       1 |        5 |
-- |  6 |       1 |        6 |
-- |  7 |       1 |        7 |
-- |  8 |       1 |        8 |
-- |  9 |       1 |        9 |
-- | 10 |       1 |       10 |
-- +----+---------+----------+
-- (10 rows)

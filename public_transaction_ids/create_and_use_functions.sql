-- Base62 encoding, which is reversible
-- Create to_base62_fixed function
CREATE OR REPLACE FUNCTION to_base62_fixed(val BIGINT, width INT DEFAULT 5)
RETURNS TEXT AS $$
DECLARE
    -- 62 chars of text
    alphabet TEXT := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    base62 TEXT := '';
    r INT;
BEGIN
    IF val < 0 THEN
        RAISE EXCEPTION 'Cannot encode negative numbers';
    END IF;

    WHILE val > 0 LOOP
        r := val % 62;
        base62 := substring(alphabet, r + 1, 1) || base62;
        val := val / 62;
    END LOOP;

    WHILE char_length(base62) < width LOOP
        base62 := '0' || base62;
    END LOOP;

    IF char_length(base62) > width THEN
        RAISE EXCEPTION 'Value too large for % characters Base62', width;
    END IF;

    RETURN base62;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;


-- Reverse from base62 string into an integer
CREATE OR REPLACE FUNCTION from_base62_fixed(str TEXT)
RETURNS BIGINT AS $$
DECLARE
    alphabet TEXT := '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
    val BIGINT := 0;
    c CHAR;
    i INT;
BEGIN
    FOR i IN 1..char_length(str) LOOP
        c := substring(str, i, 1);
        val := val * 62 + position(c in alphabet) - 1;
    END LOOP;
    RETURN val;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION obfuscate_id(id INTEGER)
RETURNS TEXT AS $$
DECLARE
    -- hexadecimal value (denoted by "0x")
    xor_key INTEGER := 0x5A3C1;  -- Any fixed number (you can change this key)
    max_val INTEGER := 62^5;     -- Max value for base62-encoded 5 chars
    encoded_val INTEGER;
BEGIN
    -- Apply XOR obfuscation, '#' is the bitwise XOR operation, aka bitwise OR, exlusive OR
    -- compares bits of id and xor_key, returning a new integer where each bit is 1 if the bits differ, and 0 if they’re the same.
    -- % modulo operator, remainder after integer division, this establishes an upper bound
    encoded_val := (id # xor_key) % max_val;
    -- RAISE NOTICE 'obfuscate_id id: %, encoded_val: %', id, encoded_val;
    -- Return base62-encoded value with 5 chars
    RETURN to_base62_fixed(encoded_val, 5);
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;


CREATE OR REPLACE FUNCTION deobfuscate_id(public_id text)
RETURNS INTEGER AS $$
DECLARE
    xor_key INTEGER := 0x5A3C1;   -- Same fixed key as above, must say the same
    max_val INTEGER := 62^5;
    val INTEGER;
BEGIN
    -- Decode the base62 string into an integer value
    val := from_base62_fixed(public_id);
    -- Reverse the XOR operation
    RETURN val # xor_key;
END;
$$ LANGUAGE plpgsql IMMUTABLE STRICT;


-- Use generated always identity, primary key, use integer not bigint
-- Use stored generated column for public_id, not null
-- Use unique constraint on public_id (prefer to add using "using index" syntax)
DROP TABLE IF EXISTS transactions;
CREATE TABLE transactions (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- 4-byte integer ID
  public_id text GENERATED ALWAYS AS (obfuscate_id(id)) STORED UNIQUE NOT NULL, -- 5-character Base62 public ID, obfuscated
  amount NUMERIC,
  description TEXT
);

ALTER TABLE transactions
    DROP CONSTRAINT IF EXISTS uniq_pub_id,
    DROP CONSTRAINT IF EXISTS public_id_length;

CREATE UNIQUE INDEX CONCURRENTLY IF NOT EXISTS idx_uniq_pub_id ON transactions (public_id);

ALTER TABLE transactions
    ADD CONSTRAINT uniq_pub_id UNIQUE USING INDEX idx_uniq_pub_id, -- depends on index above
    ADD CONSTRAINT public_id_length CHECK (LENGTH(public_id) <= 5);

INSERT INTO transactions (amount, description) VALUES
  (100.00, 'First transaction'),
  (50.00, 'Second transaction'),
  (0.25, 'Third transaction');

-- Make sure it's reversible
SELECT id, public_id, deobfuscate_id(public_id) AS reversed_id, description
FROM transactions;
--  id | public_id | reversed_id |    description
-- ----+-----------+-------------+--------------------
--   1 | 01Y9I     |           1 | First transaction
--   2 | 01Y9L     |           2 | Second transaction
--   3 | 01Y9K     |           3 | Third transaction


-- overhead
DROP TABLE IF EXISTS transactions_base;
CREATE TABLE transactions_base (
  id INTEGER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,  -- 4-byte integer ID
  amount NUMERIC,
  description TEXT
);

-- \timing
-- INSERT 0 1000000
-- Time: 2014.572 ms (00:02.015)
-- Time: 2002.176 ms (00:02.002)
-- Time: 2096.970 ms (00:02.097)
INSERT INTO transactions_base (amount, description)
SELECT
    round((random() * 1000)::numeric, 2) AS amount,
    'Transaction ' || gs.id AS description
FROM
    generate_series(1, 1000000) AS gs (id);

-- \timing on
-- "transactions" table with the public_id generation
-- INSERT 0 1000000
-- Time: 6936.973 ms (00:06.937)
-- Time: 7120.707 ms (00:07.121)
-- Time: 6804.530 ms (00:06.805)
INSERT INTO transactions (amount, description)
SELECT
    round((random() * 1000)::numeric, 2) AS amount,
    'Transaction ' || gs.id AS description
FROM
    generate_series(1, 1000000) AS gs (id);

-- 6954.070 / 2037.906 ≈ 3.41× slower

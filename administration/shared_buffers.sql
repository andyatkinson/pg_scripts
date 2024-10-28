-- 8kb blocks are the unit, by default
-- https://stackoverflow.com/a/24550710/126688
-- e.g. no unit set, 16384 for SHOW shared_buffers, is 8kb blocks
-- For 1 block: ≈ 0.0078125MB
-- (16384*8)/1024 = 128MB

SELECT
    current_setting('shared_buffers') AS shared_buffers_8kb_blocks,
    (current_setting('shared_buffers')::bigint * 8) / 1024 / 1024 AS shared_buffers_gb;

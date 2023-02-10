TRUNCATE temp_backfill.trip_requests_intermediate;

INSERT INTO temp_backfill.trip_requests_intermediate (rider_id, rider_first_name)
SELECT id, first_name
FROM riders
WHERE id >= 1 AND id < 10000;

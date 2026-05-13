SELECT
  CASE
    WHEN status = 'streaming'
      THEN EXTRACT(EPOCH FROM (now() - last_msg_send_time))
    ELSE 0
  END AS replica_lag_seconds,
  status,
  sender_host,
  last_msg_send_time,
  last_msg_receipt_time
FROM pg_stat_wal_receiver;

\watch 2 -- wait until it's zero

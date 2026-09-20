CREATE OR REPLACE VIEW `round-cable-381420.cloud_solution.deduplicated_logs`
AS
            
 WITH flattened_logs AS (
-- Parse data from 'event_payload' column into separate columns
  SELECT
      log_id,
      TIMESTAMP(timestamp) AS event_timestamp,

      JSON_EXTRACT_SCALAR(event_payload, '$.event_name') AS event_name,
      JSON_EXTRACT_SCALAR(event_payload, '$.user_id') AS user_id,
      JSON_EXTRACT_SCALAR(event_payload, '$.device.os') AS device_os,
      JSON_EXTRACT_SCALAR(event_payload, '$.device.metadata.button_color') AS       
      button_color
    FROM `round-cable-381420.cloud_solution.dirty_event_logs`
), 

cleaned_logs AS (
-- Finds duplicate events partitioning by user_id, event_name, and event_timestamp
  SELECT log_id, 
  event_timestamp, 
  event_name, 
  user_id, 
  device_os, 
  button_color,
  ROW_NUMBER() OVER(
      PARTITION BY user_id, event_name, event_timestamp 
      ORDER BY log_id
    ) as row_num
  FROM flattened_logs
)
-- Deletes duplicate records where the row number > 1
  SELECT log_id, 
  event_timestamp, 
  event_name, 
  user_id, 
  device_os, 
  button_color,
  LAG(event_timestamp) OVER(PARTITION BY user_id ORDER BY event_timestamp ASC) AS prev_timestamp
  FROM cleaned_logs WHERE row_num = 1
-- The prev_timestamp column is used to calculate session numbers. See the 'cloud_user_session_creating' query for details

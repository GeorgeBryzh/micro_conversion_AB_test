CREATE OR REPLACE VIEW `round-cable-381420.cloud_solution.ab_click_trial_conversion` AS
-- Calculates users completed micro-conversions (clicked on the free_trial) and their conversion rates. Methrics scoped per button color and device OS
SELECT button_color, 
device_os,
COUNT(distinct user_id) AS total_users,
COUNT(DISTINCT CASE WHEN event_name = 'click_trial' THEN user_id END) AS converted_users,
ROUND(
  SAFE_DIVIDE(
      COUNT(DISTINCT CASE WHEN event_name = 'click_trial' THEN user_id END),
      COUNT(DISTINCT user_id)
  )*100, 2
) AS conversion_rate_pct
FROM `round-cable-381420.cloud_solution.deduplicated_logs` 
WHERE event_name IN ('view_pricing', 'click_trial')
GROUP BY button_color, device_os
ORDER BY device_os asc;

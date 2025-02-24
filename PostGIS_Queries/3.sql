-- Add a new column in trip_data to store the half-hour interval
ALTER TABLE public.trip_data
ADD COLUMN half_hour_starttime TIMESTAMP;

-- Update the new column with half-hour intervals based on start_time
UPDATE trip_data
SET half_hour_starttime = 
    DATE_TRUNC('hour', start_time::timestamp) + 
    INTERVAL '30 minutes' * FLOOR(EXTRACT(MINUTE FROM start_time::timestamp) / 30);

SELECT DATE_TRUNC('hour', start_time::timestamp) FROM trip_data;

-- business goal: optimize van routes for replenishing bike stations
-- task: create a buffer of 1 kilometers around the top 3 bike stations where most of the trips started from, 
---- and perform a spatial join to analyze which nearby stations fall within a 1 km radius for easy servicing
-- hint: use ST_Buffer() and ST_Intersects() functions from PostGIS


-- Step 1: Identify top 3 stations where most trips started from
SELECT start_station_id, COUNT(*) AS total_trips
FROM public.trip_data
GROUP BY start_station_id
ORDER BY total_trips DESC
LIMIT 3;

-- Step 2: Create buffers around top 3 stations
WITH top_stations AS (
    SELECT station_id, geom
    FROM public.stations
    WHERE station_id IN (SELECT start_station_id
                         FROM public.trip_data
                         GROUP BY start_station_id
                         ORDER BY COUNT(*) DESC
                         LIMIT 3)
)
SELECT station_id, ST_Buffer(geom, 1000) AS buffer_geom -- buffer of 1 km
FROM top_stations;

-- Step 3: Perform spatial join 
WITH top_station_buffers AS (
    SELECT station_id, ST_Buffer(geom, 1000) AS buffer_geom
    FROM public.stations
    WHERE station_id IN (SELECT start_station_id
                         FROM public.trip_data
                         GROUP BY start_station_id
                         ORDER BY COUNT(*) DESC
                         LIMIT 3)
)
SELECT s.station_id, tsb.station_id AS top_station_id
FROM public.stations s
JOIN top_station_buffers tsb
ON ST_Intersects(s.geom, tsb.buffer_geom)
ORDER BY top_station_id;
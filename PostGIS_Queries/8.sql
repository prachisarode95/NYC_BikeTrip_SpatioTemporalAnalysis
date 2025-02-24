-- Objective: determine how many bike trips started in each census tract.

-- Step 1: assign each bike station to the appropriate census tract using a spatial join
SELECT 
    s.station_id, 
    nyct.id, 
    s.geom
FROM 
    stations AS s
JOIN 
    nyct2020 AS nyct 
ON 
    ST_Within(s.geom,nyct.wkb_geometry);

-- Step 2: joining stations with trip data
WITH station_census AS (
	SELECT 
	    s.station_id, 
	    nyct.id, 
	    s.geom
	FROM 
	    stations AS s
	JOIN 
	    nyct2020 AS nyct 
	ON 
	    ST_Within(s.geom,nyct.wkb_geometry)
)
SELECT 
    t.ride_id, 
    t.half_hour_starttime, 
    sc.id, 
    t.start_station_id
FROM 
    trip_data AS t
LEFT JOIN 
    station_census AS sc
ON 
    t.start_station_id = sc.station_id;
   
-- Step 3: grouping and counting trips by census tract 
WITH station_census AS (
	SELECT 
	    s.station_id, 
	    nyct.id, 
	    s.geom, 
	    nyct.wkb_geometry
	FROM 
	    stations AS s
	JOIN 
	    nyct2020 AS nyct 
	ON 
	    ST_Within(s.geom,nyct.wkb_geometry)
)
SELECT 
    sc.id, 
    COUNT(t.ride_id) AS trip_count, 
    sc.wkb_geometry
FROM 
    trip_data AS t
LEFT JOIN 
    station_census AS sc
ON 
    t.start_station_id = sc.station_id
GROUP BY 
    sc.id, sc.wkb_geometry
ORDER BY 
    trip_count DESC;
    
-- Step 4: save as table for visualization
create TABLE ct_trip_count_04_04 AS
WITH station_census AS (
	SELECT 
	    s.station_id, 
	    nyct.id, 
	    s.geom, 
	    nyct.wkb_geometry
	FROM 
	    stations AS s
	JOIN 
	    nyct2020 AS nyct 
	ON 
	    ST_Within(s.geom,nyct.wkb_geometry)
)
SELECT 
    sc.id, 
    COUNT(t.ride_id) AS trip_count, 
    sc.wkb_geometry
FROM 
    trip_data AS t
LEFT JOIN 
    station_census AS sc
ON 
    t.start_station_id = sc.station_id
GROUP BY 
    sc.id, sc.wkb_geometry
ORDER BY 
    trip_count DESC;
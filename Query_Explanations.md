# Temporal Operations

## Data explorations with SQL (Referred to 1.sql file)

1.  **Double-check whether the PostGIS extension exists in our system:**
    
    ```
    SELECT * FROM pg_available_extensions;
    ```
    This query lists all available extensions. If PostGIS is not listed, you may need to install it.

2.  **Add the PostGIS extension to our workspace:**
     
    ```
    CREATE EXTENSION POSTGIS;
    ```
    This command enables the PostGIS extension within your database.

3.  **Create `stations` Table:**

    ```
    CREATE TABLE public.stations (
        station_id VARCHAR(50) PRIMARY KEY,
        station_lat FLOAT4,
        station_lon FLOAT4
    );
    ```
    This creates the `stations` table to store station information, including latitude and longitude.

4.  **Create `trip_data` Table:**

    ```
    CREATE TABLE public.trip_data (
        ride_id VARCHAR(50) PRIMARY KEY,
        bike_type VARCHAR(50),
        start_time VARCHAR(50),
        end_time VARCHAR(50),
        start_station_id VARCHAR(50),
        end_station_id VARCHAR(50)
    );
    ```
    This creates the `trip_data` table to store trip details, including start and end times, station IDs, and bike types.

## Time-based analysis grouping trips by half-hour intervals (Referred to 2.sql file)

  **Question 1: How many stations does BigApple BikeShare company have?**

  ```
  SELECT COUNT(*) AS station_count
  FROM public.stations;
  ```
  This query counts the total number of rows in the `stations` table, which represents the total number of bike stations. The result is aliased as `station_count`.

  **Question 2: How many trips were taken on September 17th?**

  ```
  SELECT COUNT(*) AS trip_count
  FROM public.trip_data
  WHERE start_time::date = '2024-09-17';
  ```
  This query counts the number of trips that started on September 17th, 2024. It filters the `trip_data` table based on the `start_time` column, casting it to a 
  date for comparison. The result is aliased as `trip_count`.

  **Question 3: What percentage of bike trips used an e-bike?**

  ```
  SELECT(COUNT(CASE WHEN bike_type = 'ebike' THEN 1 END) * 100.0 / COUNT(*)) AS ebike_percentage
  FROM public.trip_data;
  ```
  This query calculates the percentage of trips made using e-bikes. It uses a `CASE` statement to count the number of trips where `bike_type` is 'ebike', then 
  divides that count by the total number of trips and multiplies by 100.0 to get the percentage. The result is aliased as `ebike_percentage`.

  **Question 4: Which bike station had the most starting trips on that day?**
  
  ```
  SELECT start_station_id, COUNT(ride_id) AS trip_count
  FROM public.trip_data
  GROUP BY start_station_id
  ORDER BY trip_count desc
  LIMIT 1;
  ```
  This query finds the station with the most starting trips. It groups trips by `start_station_id`, counts the number of trips per station, orders the results in 
  descending order of trip count, and then uses `LIMIT 1` to retrieve only the top station. The trip count is aliased as `trip_count`.

  **Question 5: What’s the average length of a bike trip?**

  ```
  SELECT AVG(END_TIME::timestamp - START_TIME::timestamp) AS avg_trip_duration
  FROM public.trip_data;
  ```
  This query calculates the average duration of bike trips. It subtracts the `START_TIME` from the `END_TIME`, casting both to timestamps, and then calculates the 
  average of the resulting durations using the `AVG()` function. The result is aliased as `avg_trip_duration`.

## Time-based analysis analyzing patterns by time of the day (Referred to 3.sql)
 
 **Add a new column in trip_data to store the half-hour interval:**
   
 ```
 ALTER TABLE public.trip_data
 ADD COLUMN half_hour_starttime TIMESTAMP;
 ```
 This query adds a new `TIMESTAMP` column named `half_hour_starttime` to the `trip_data` table. This column will store the start time rounded down to the nearest 
 half-hour.

 **Update the new column with half-hour intervals based on start_time:**

 ```
 UPDATE trip_data
 SET half_hour_starttime =
 DATE_TRUNC('hour', start_time::timestamp) +
 INTERVAL '30 minutes' * FLOOR(EXTRACT(MINUTE FROM start_time::timestamp) / 30);
 ```
 This query updates the half_hour_starttime column by calculating half-hour intervals from the start_time. The process involves several steps:

- DATE_TRUNC('hour', start_time::timestamp): This extracts the hour from start_time, setting minutes and seconds to zero.
- EXTRACT(MINUTE FROM start_time::timestamp) / 30: This determines which half-hour interval the start_time belongs to, yielding either 0 or 1.
- FLOOR(...): This rounds down the result to the nearest integer, providing a valid index for intervals.
- INTERVAL '30 minutes' * ...: This adds either 0 or 30 minutes to the truncated hour, effectively rounding start_time to the nearest half-hour interval.

**Example of Hour Truncation:**

```
SELECT DATE_TRUNC('hour', START_TIME::timestamp) FROM trip_data;
```
This query demonstrates how the `DATE_TRUNC('hour', ...)` function works, showing the truncated hour portion of the `start_time`.

# Spatial Operations

## Reproject census tract boundary geometry with PostGIS  (Referred to 4.sql)

**Task:** Determine the times when the most bike trips start, listing these times in descending order 
from the busiest to the least busy, along with the corresponding bike trip counts.

```
SELECT half_hour_starttime, COUNT(*) AS trip_count
FROM public.trip_data
GROUP BY half_hour_starttime
ORDER BY trip_count DESC;
```

## Creating geometric columns and defining projections (Referred to 5.sql)

-- Step 1: Transform census tract boundary files with UTM 18N projection

```
ALTER TABLE nyct2020
ALTER COLUMN wkb_geometry type geometry(MultiPolygon, 32618)
USING ST_TRANSFORM(ST_SetSRID(wkb_geometry,4326), 32618);
```

## Spatial analysis: analyzing patterns with spatial join (Referred to 6.sql)

-- Step 1: Turn stations table into a geospatial data format and set the correct projection

```
ALTER TABLE public.stations
ADD COLUMN geom geometry(Point, 4326);
```
-- Step 2: Populate the new geom column using lat and lon columns

```
UPDATE public.stations
SET geom = ST_SetSRID(ST_MakePoint(station_lon, station_lat), 4326);
```

-- Step 3: Transform the geometry to UTM Zone 18N projection (EPSG: 32618)

```
ALTER TABLE public.stations
ALTER COLUMN geom 
TYPE geometry(Point, 32618)
USING ST_Transform(geom, 32618);
```

## Transforming Station Data to Geospatial Format (Referred to 7.sql)

-- Step 1: Check out the spatial_ref_sys added by PostGIS where SRID = 32618

```
SELECT * FROM spatial_ref_sys
WHERE srid = 32618;
```
-- Step 2: Find out what SRID is currently being used by the 'nyct2020' table

```
SELECT FIND_SRID('public', 'nyct2020', 'wkb_geometry');
```

# Geospatial Transformation Queries
  
## Spatial analysis: identifying nearby stations with a  buffer (Referred to 8.sql)

-- Step 1: assign each bike station to the appropriate census tract using a spatial join

```
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
```
This query performs a spatial join between the stations and nyct2020 tables, utilizing ST_Within to determine which census tract (nyct) contains each station (s). The output includes the station ID, census tract ID, and station geometry. In summary, it assigns each station to its corresponding census tract.

-- Step 2: joining stations with trip data

```
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
```
This query extends the previous one by creating a Common Table Expression (CTE) named station_census. It then performs a LEFT JOIN between the trip_data table and station_census using start_station_id. This process incorporates the census tract ID into each trip record, linking it to the trip's starting station. In summary, it adds census tract information to the trip data.

-- Step 3: grouping and counting trips by census tract

```
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
```
This query builds on the previous Common Table Expression (CTE) by grouping the results based on census tract ID (sc.id) and geometry (sc.wkb_geometry). It employs COUNT(t.ride_id) to tally the number of trips initiated in each census tract and sorts the results in descending order of trip_count. In summary, it counts the trips starting from each census tract.
    
-- Step 4: save as table for visualization

```
CREATE TABLE ct_trip_count AS
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
```
This query mirrors Step 3 but utilizes CREATE TABLE ct_trip_count AS to store the results in a new table called ct_trip_count. This approach makes the trip counts per census tract readily accessible for visualization and further analysis.

## Optimizing Van Routes for Bike Station Replenishment (Referred to 9.sql)

**Goal: Create a buffer of 1 kilometer around the top 3 bike stations where most of the trips started from, and perform a spatial join to analyze which nearby stations fall within a 1 km radius for easy servicing**

-- Step 1: Identify the top 3 stations where most trips started from

```
SELECT start_station_id, COUNT(*) AS total_trips
FROM public.trip_data
GROUP BY start_station_id
ORDER BY total_trips DESC
LIMIT 3;
```
This query identifies the top 3 stations with the highest number of starting trips. It groups trips by start_station_id, counts the trips for each station, orders them in descending order based on trip count, and limits the result to the top 3.

-- Step 2: Create buffers around top 3 stations

```
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
```
This query generates a 1 km buffer around the geometries of the top three stations identified in Step 1. It utilizes a Common Table Expression (CTE) to select these top three stations and then employs the ST_Buffer() function to create a 1,000-meter (1 km) buffer around each station's geometry.

-- Step 3: Perform spatial join

```
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
```
This query executes a spatial join between the stations table and the buffered geometries of the top three stations. It leverages a Common Table Expression (CTE) to create the buffers and employs the ST_Intersects() function to identify which stations lie within the 1 km buffer of the top stations. The result includes the station_id of the nearby stations along with the corresponding top_station_id they are proximate to.

# Spatio-Temporal Analysis and Visualization 

## Spatio-Temporal Trip Data Analysis (Referred to 10.sql)

**Goal: Create a new table named spatio_temporal_visualization that includes total trip count by census tract and half-hour intervals**

```
CREATE TABLE spatio_temporal_visualization AS
SELECT half_hour_starttime,
    nyct2020.id AS census_tract,
    nyct2020.wkb_geometry AS geom,
    COUNT(trip_data.ride_id) AS trip_count
FROM public.trip_data
JOIN public.stations ON trip_data.start_station_id = stations.station_id
JOIN public.nyct2020 ON ST_WITHIN(stations.geom, nyct2020.wkb_geometry)
GROUP BY half_hour_starttime, census_tract
ORDER BY census_tract, half_hour_starttime;
```

## Visualize Time-Series data in QGIS with Animated Choropleth Map
I created a time-series data visualization using QGIS's 'Time Manager' plugin to animate a choropleth map.

**Final Result:**
<video src="https://github.com/user-attachments/assets/d20f7af8-2083-4a39-814f-51caa5fa1abe" controls width="640"></video>

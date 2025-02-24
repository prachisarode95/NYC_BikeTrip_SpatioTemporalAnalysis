# Temporal operations

## Data explorations with SQL (Referred to 1.sql file)

1.  **Check for PostGIS Extension:**

    ```sql
    -- Double check whether the PostGIS extension exists in our system
    SELECT * FROM pg_available_extensions;
    ```

    This query lists all available extensions. If PostGIS is not listed, you may need to install it.

2.  **Enable PostGIS Extension:**

    ```sql
    -- Add the PostGIS extension to our workspace
    CREATE EXTENSION postgis;
    ```

    This command enables the PostGIS extension within your database.

3.  **Create `stations` Table:**

    ```sql
    -- Create table structure for stations.csv
    CREATE TABLE public.stations (
        station_id VARCHAR(50) PRIMARY KEY,
        station_lat FLOAT4,
        station_lon FLOAT4
    );
    ```

    This creates the `stations` table to store station information, including latitude and longitude.

4.  **Create `trip_data` Table:**

    ```sql
    -- Create table structure for trip_data.csv
    CREATE TABLE public.trip_data (
        ride_id VARCHAR(50) PRIMARY KEY,
        bike_type VARCHAR(50),
        start_time VARCHAR(50),
        end_time VARCHAR(50),
        start_station_id VARCHAR(50),
        end_station_id VARCHAR(50)
    );
    This creates the `trip_data` table to store trip details, including start and end times, station IDs, and bike types.
    ```
    
## Time-based analysis grouping trips by half-hour intervals (Referred to 2.sql file)

This section provides SQL queries used to analyze the bike share data, along with explanations of the questions they answer.

**Using `public.stations` Table**

  **Question 1: How many stations does BigApple BikeShare company have?**

    ```sql
    select count(*) as station_count
    from public.stations;
    ```

    This query counts the total number of rows in the `stations` table, which represents the total number of bike stations. The result is aliased as `station_count`.

**Using `public.trip_data` Table**

  **Question 2: How many trips were taken on September 17th?**

    ```sql
    select count(*) as trip_count
    from public.trip_data
    where start_time::date = '2024-09-17';
    ```

    This query counts the number of trips that started on September 17th, 2024. It filters the `trip_data` table based on the `start_time` column, casting it to a date for comparison. The result is aliased as `trip_count`.

  **Question 3: What percentage of bike trips used an e-bike?**

    ```sql
    select
        (count(case when bike_type = 'ebike' then 1 end) * 100.0 / count(*)) as ebike_percentage
    from public.trip_data;
    ```

    This query calculates the percentage of trips made using e-bikes. It uses a `CASE` statement to count the number of trips where `bike_type` is 'ebike', then divides that count by the total number of trips and multiplies by 100.0 to get the percentage. The result is aliased as `ebike_percentage`.

  **Question 4: Which bike station had the most starting trips on that day?**

    ```sql
    select start_station_id, count(ride_id) as trip_count
    from public.trip_data
    group by start_station_id
    order by trip_count desc
    limit 1;
    ```

    This query finds the station with the most starting trips. It groups trips by `start_station_id`, counts the number of trips per station, orders the results in descending order of trip count, and then uses `LIMIT 1` to retrieve only the top station. The trip count is aliased as `trip_count`.

  **Question 5: What’s the average length of a bike trip?**

    ```sql
    select avg(end_time::timestamp - start_time::timestamp) as avg_trip_duration
    from public.trip_data;
    ```

    This query calculates the average duration of bike trips. It subtracts the `start_time` from the `end_time`, casting both to timestamps, and then calculates the average of the resulting durations using the `AVG()` function. The result is aliased as `avg_trip_duration`.

## Time-based analysis analyzing patterns by time of the day (Referred to 3.sql)

This section describes SQL queries used to modify the `trip_data` table to add a column representing the half-hour start time interval.

1.  **Add `half_hour_starttime` Column:**

    ```sql
    -- Add a new column in trip_data to store the half-hour interval
    ALTER TABLE public.trip_data
    ADD COLUMN half_hour_starttime TIMESTAMP;
    ```

    This query adds a new `TIMESTAMP` column named `half_hour_starttime` to the `trip_data` table. This column will store the start time rounded down to the nearest half-hour.

2.  **Populate `half_hour_starttime` Column:**

    ```sql
    -- Update the new column with half-hour intervals based on start_time
    UPDATE trip_data
    SET half_hour_starttime =
        DATE_TRUNC('hour', start_time::timestamp) +
        INTERVAL '30 minutes' * FLOOR(EXTRACT(MINUTE FROM start_time::timestamp) / 30);
    ```

    This query updates the `half_hour_starttime` column with the calculated half-hour intervals. It performs the following operations:

    * `DATE_TRUNC('hour', start_time::timestamp)`: Extracts the hour portion of the `start_time` and sets the minutes and seconds to zero.
    * `EXTRACT(MINUTE FROM start_time::timestamp) / 30`: Calculates which half-hour interval the start time falls into (0 or 1).
    * `FLOOR(...)`: Rounds the result down to the nearest integer.
    * `INTERVAL '30 minutes' * ...`: Adds either 0 or 30 minutes to the truncated hour, resulting in the nearest half-hour interval.

3.  **Example of Hour Truncation:**

    ```sql
    SELECT DATE_TRUNC('hour', start_time::timestamp) FROM trip_data;
    ```

    This query demonstrates how the `DATE_TRUNC('hour', ...)` function works, showing the truncated hour portion of the `start_time`.

# Spatial operations

 ## Reproject census tract boundary geometry with postgis  (Referred to 4.sql)
 This section details an SQL query used to analyze bike usage patterns throughout the day, focusing on peak usage times.

**Goal:** Understand the bike usage throughout the day.

**Task:** Determine the times when the most bike trips start, listing these times in descending order from the busiest to the least busy, along with the corresponding bike trip counts.

**Hint:** `GROUP BY()`, `ORDER BY()`

```sql
select half_hour_starttime, count(*) as trip_count
from public.trip_data
group by half_hour_starttime
order by trip_count DESC;
```

## Creating geometric columns and defining projections (Referred to 5.sql)
This section details an SQL query used to transform the geometry of census tract boundary data to the UTM Zone 18N projection (EPSG: 32618).

### Geometry Transformation Query

**Goal:** Transform census tract boundary files with UTM 18N projection.

**Hints:**

* The projection we would like to use for our project is UTM zone 18N (EPSG: 32618).
* Working with projection `ST_Transform()` and `ST_SetSRID` - [https://postgis.net/documentation/tips/st-set-or-transform/](https://postgis.net/documentation/tips/st-set-or-transform/)

```sql
-- Transform census tract boundary files with UTM 18N projection
alter table nyct2020
alter column wkb_geometry type geometry(MultiPolygon, 32618)
using ST_Transform(ST_SetSRID(wkb_geometry,4326), 32618);
```

## Spatial analysis: analyzing patterns with spatial join (Referred to 6.sql)



## Transforming Station Data to Geospatial Format (Referred to 7.sql)
This section describes SQL queries used to convert station latitude and longitude data into a geospatial format (Point geometry) and transform it to the UTM Zone 18N projection (EPSG: 32618).

### Geospatial Transformation Queries

**Hints:**

* The spatial reference ID for WGS84 latitude and longitude is 4326.
* The projection we would like to use for our project is UTM zone 18N (EPSG: 32618).
* Working with projection `ST_Transform()` and `ST_SetSRID` - [https://postgis.net/documentation/tips/st-set-or-transform/](https://postgis.net/documentation/tips/st-set-or-transform/)

**Goal:** Turn the `stations` table into a geospatial data format and set the correct projection.

**Step 1: Add a new geometry column to the `stations` table**

```sql
-- Step 1: Add a new geometry column to the bike_stations table
ALTER table public.stations
ADD COLUMN geom geometry(Point, 4326);
```
 
 ## Creating a choropleth map in qgis (explain how i created a choropleth map using qgis interface)
 
 ## Spatial analysis: identifying nearby stations with a  buffer (Referred to 8.sql)


 ## Optimizing Van Routes for Bike Station Replenishment (Referred to 9.sql)

  This section provides SQL queries to optimize van routes for replenishing bike stations, focusing on identifying stations within a 1km radius of the top 3 busiest stations.

```sql
-- Business goal: optimize van routes for replenishing bike stations
-- Task: create a buffer of 1 kilometers around the top 3 bike stations where most of the trips started from,
---- and perform a spatial join to analyze which nearby stations fall within a 1 km radius for easy servicing
-- hint: use ST_Buffer() and ST_Intersects() functions from PostGIS

-- Step 1: Identify top 3 stations where most trips started from
SELECT start_station_id, COUNT(*) AS total_trips
FROM public.trip_data
GROUP BY start_station_id
ORDER BY total_trips DESC
LIMIT 3;

-- Explanation:
-- This query identifies the top 3 stations with the highest number of starting trips.
-- It groups trips by start_station_id, counts the trips for each station,
-- orders them in descending order based on trip count, and limits the result to the top 3.

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

-- Explanation:
-- This query creates a 1km buffer around the geometry of the top 3 stations identified in Step 1.
-- It uses a CTE (Common Table Expression) to select the top 3 stations and then uses ST_Buffer()
-- to create a buffer of 1000 meters (1 km) around each station's geometry.

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

-- Explanation:
-- This query performs a spatial join between the stations table and the buffered top 3 stations.
-- It uses a CTE to create the buffers and then uses ST_Intersects() to find stations
-- that fall within the 1km buffer of the top stations.
-- It returns the station_id of the nearby stations and the top_station_id they are near.
```

# Spatio-temporal analysis and visualization 

## Spatio-Temporal Trip Data Analysis (Referred to 10.sql)

This section explains an SQL query used to group trip data by both temporal (half-hour intervals) and spatial (census tracts) dimensions.

```sql
-- goal: group trip data by both temporal and spatial dimensions
-- task: create a new table named spatio_temporal_visualization that includes
--       total trip count by census tract and half hour intervals

create table spatio_temporal_visualization as
select half_hour_starttime,
    nyct2020.id as census_tract,
    nyct2020.wkb_geometry as geom,
    count(trip_data.ride_id) as trip_count
from public.trip_data
join public.stations on trip_data.start_station_id = stations.station_id
join public.nyct2020 on ST_Within(stations.geom, nyct2020.wkb_geometry)
group by half_hour_starttime, census_tract
order by census_tract, half_hour_starttime;
```

## Visualize time series data in qgis with choropleth map
add explanation on how I used time manager plugin to create a visualization of the choropleth map and convert it into a video.

### Final Result
<video src="https://github.com/user-attachments/assets/d20f7af8-2083-4a39-814f-51caa5fa1abe" controls width="640"></video>


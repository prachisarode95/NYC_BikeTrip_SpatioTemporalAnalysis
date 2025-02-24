-- hint 1: the spatial reference id for WGS84 latitude and longitude is 4326
-- hint 2: the projection we would like to use for our project is UTM zone 18N (EPSG: 32618)
-- hint 3: working with projection ST_Transform() and ST_SetSRID - https://postgis.net/documentation/tips/st-set-or-transform/

-- Goal: turn stations table into geospatial data format and set the correct projection
-- Step 1: Add a new geometry column to the bike_stations table
ALTER table public.stations
ADD COLUMN geom geometry(Point, 4326);

-- Step 2: Populate the new geom column using lat and lon columns
UPDATE public.stations
SET geom = ST_SetSRID(ST_MakePoint(station_lon, station_lat), 4326);

-- Step 3: Transform the geometry to UTM Zone 18N projection (EPSG: 32618)
ALTER TABLE public.stations
ALTER COLUMN geom 
TYPE geometry(Point, 32618)
USING ST_Transform(geom, 32618);



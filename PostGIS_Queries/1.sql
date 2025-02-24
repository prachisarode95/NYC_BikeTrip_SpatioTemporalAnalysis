-- double check whether postgis extension exists in our system 
select * from pg_available_extensions;

-- add extension to our workspace
create extension postgis;

-- create table structure for stations.csv
CREATE TABLE public.stations (
	station_id varchar(50) NULL,
	station_lat float4 NULL,
	station_lon float4 NULL,
	primary key (station_id)
);

-- create table structure for trip_data.csv
CREATE TABLE public.trip_data (
	ride_id varchar(50) NULL,
	bike_type varchar(50) NULL,
	start_time varchar(50) NULL,
	end_time varchar(50) NULL,
	start_station_id varchar(50) NULL,
	end_station_id varchar(50) null,
	primary key (ride_id)
);
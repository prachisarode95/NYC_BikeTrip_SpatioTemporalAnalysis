-- goal: group trip data by both ttemporal and spatial dimensions 
-- task: create a new table named spatio_temporal_visualization_05_01 that includes 
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
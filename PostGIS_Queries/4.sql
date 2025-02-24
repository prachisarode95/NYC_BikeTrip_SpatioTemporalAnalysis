-- Goal: understand the bike usage throughout the day.
-- Task: determine the times when the most bike trips start, listing these times in descending order from the busiest to the least busy, along with the corresponding bike trip counts. 
-- Hint: GROUP_BY(), ORDER_BY()

select half_hour_starttime, count(*) as trip_count
from public.trip_data 
group by half_hour_starttime 
order by trip_count DESC;
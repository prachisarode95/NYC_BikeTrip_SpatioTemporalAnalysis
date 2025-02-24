-- hint 1: the projection we would like to use for our project is UTM zone 18N (EPSG: 32618)
-- hint 2: working with projection ST_Transform() and ST_SetSRID - https://postgis.net/documentation/tips/st-set-or-transform/

-- Goal: transform census tract boundary files with UTM 18N projection
alter table nyct2020
alter column wkb_geometry type geometry(MultiPolygon, 32618)
using ST_Transform(ST_SetSRID(wkb_geometry,4326), 32618);

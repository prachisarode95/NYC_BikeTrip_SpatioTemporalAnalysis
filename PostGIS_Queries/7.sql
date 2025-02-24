-- Check out the spatial_ref_sys added by PostGIS where SRID = 32618
select * from spatial_ref_sys
where srid = 32618;

-- find out what SRID is currently being used by nyct2020 table
select find_srid('public', 'nyct2020', 'wkb_geometry');
# 🌿 NYC Rush Hour Bike Demand Analysis using PostGIS

This project analyzes rush hour bike demand patterns in New York City using **PostgreSQL + PostGIS**, **QGIS**, and **Python**. Inspired by a LinkedIn Learning course on spatial data science with PostgreSQL, the goal was to practice and demonstrate advanced spatio-temporal data analysis and geospatial visualization using real-world-like synthetic datasets.

---

**Project Overview:**

* **Data Review:** I reviewed the provided data, which aimed to understand bike demand patterns during rush hours in New York City.
* **Dataset Acquisition and Processing:** I utilized two primary datasets. The first, containing bike station information, consisted of two files: "Stations" (station ID, latitude, and longitude) and trip data (trip ID, start/end times, bike type, and start/end station IDs). By joining these files, I mapped each trip's geographical path, revealing station usage and spatial patterns. I focused on data from September 17, 2024, demonstrating a methodology applicable to various time frames and zones.
* **Census Tract Integration:** I incorporated the 2020 Census Tract Boundary File for New York City from the US Census Bureau. This dataset provided geometry columns defining borough boundaries, tract IDs, and other attributes.
* **Rationale for Census Tracts:** I strategically chose census tracts over other geographic boundaries (neighborhoods, block groups) for their standardized, statistically reliable approach to spatial analysis. Aggregating trips into census tracts allowed me to identify broader demand trends that station-level data alone could not reveal. This enabled a more accurate understanding of demand fluctuations across larger areas, aiding in strategic bike repositioning.
* **Spatial and Temporal Analysis:** I performed spatial and temporal analysis using SQL queries within PostGIS, and visualized the results using QGIS and Python. This allowed me to discover and display the patterns of bike usage during rush hour.
* **Visualization:** I created visualizations using Python to show the results of the SQL queries.

---

## 📊 Project Objectives

1. Import and manage NYC bike trip data using a PostgreSQL/PostGIS database.
2. Perform spatial and temporal analysis using SQL queries within the QGIS DB Manager.
3. Integrate US Census Tract boundaries to generalize bike demand patterns.
4. Visualize analysis results with QGIS and Python.
5. Apply spatial joins, time grouping, projections, and buffer analysis for data-driven planning.

---

**Exploration of US census data and NYC stations & trip data:**

This project analyzes New York City rush hour bike demand using New York City census tract boundary data and synthetic trip data.

1. The first dataset comprises bike station information and trip details. Two files provide station IDs, latitudes, and longitudes ("Stations") and individual trip data, including unique IDs, start/end times, bike type, and start/end station IDs. Joining these files allows mapping trip origins and destinations, revealing station usage and spatial patterns. This project focuses on September 17, 2024 data, but the methodology applies to other timeframes and locations.

2. The second key dataset is the US Census Bureau's 2020 Census Tract Boundary File for New York City, containing geometry columns defining borough boundaries, tract IDs, and other attributes. While bike station locations provide precise origin-destination points, aggregating trips by census tract reveals broader spatial demand trends obscured at the station level. This approach identifies demand fluctuations across larger areas, aiding strategic bike repositioning.

Census tracts were chosen over other geographic boundaries (e.g., neighborhoods, census block groups) because they offer a standardized, statistically reliable approach to analyzing city areas. Neighborhood definitions are less consistent and less suitable for precise data-driven analysis. Using census tracts ensures accuracy and compatibility with other datasets, facilitating informed decisions regarding bike supply and demand management.

---

## 📅 Dataset Overview

### 1. **Bike Station and Trip Data (Synthetic)**

* **stations.csv**: Contains station ID, latitude, and longitude.
* **trip\_data.csv**: Contains ride ID, bike type, start/end times, and station IDs.
* Focused on trips from **September 17, 2024**.

### 2. **2020 US Census Tract Boundaries (NYC)**

* Source: US Census Bureau
* Contains geometry and attributes like borough names and tract IDs

**Why Census Tracts?**

* Chosen for their standardization and statistical reliability.
* Allow aggregation of trips to analyze broader spatial trends.
* Superior to neighborhoods or block groups for consistent and comparable spatial units.

---

## 🎓 Tools & Technologies

| Tool           | Purpose                                           |
| -------------- | ------------------------------------------------- |
| **PostgreSQL** | Primary database for tabular and spatial data     |
| **PostGIS**    | Enables spatial functions and geometry processing |
| **QGIS**       | Spatial data visualization, time-based mapping    |
| **Python**     | Data processing and charting (Pandas, Matplotlib) |

---

## 📒 Key Workflows & Highlights

* Created `stations` and `trip_data` tables with spatial geometry columns.
* Added PostGIS extension and reprojected geometries to UTM Zone 18N (EPSG:32618).
* Converted start times to half-hour intervals using `DATE_TRUNC()` and `EXTRACT()`.
* Spatially joined bike stations with census tracts using `ST_Within()`.
* Aggregated trip counts by tract and time interval.
* Identified top bike stations and used buffer analysis to find nearby serviceable stations.

### Example Query: Time-based Aggregation

```sql
SELECT half_hour_starttime, COUNT(*) AS trip_count
FROM public.trip_data
GROUP BY half_hour_starttime
ORDER BY trip_count DESC;
```

### Example Query: Spatial Join

```sql
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

---

## 📊 Visualizations

* **QGIS:** Used DB Manager to execute spatial queries and visualize data.
* **Time Manager Plugin:** Animated choropleth maps showing trip count evolution.
* **Python:** Additional bar plots and time series charts using Pandas & Matplotlib.

![QGIS Example](./images/qgis_map.png)

---

## 📆 Setup Instructions

### 1. Clone Repository

```bash
git clone https://github.com/yourusername/NYC_BikeRush_PostGIS.git
cd NYC_BikeRush_PostGIS
```

### 2. Install PostgreSQL and PostGIS

```sql
CREATE DATABASE nyc_bike_trips;
\c nyc_bike_trips;
CREATE EXTENSION postgis;
```

### 3. Install QGIS and Python Requirements

```bash
pip install -r requirements.txt
```

### 4. Load Data Using QGIS DB Manager

* Load `stations.csv`, `trip_data.csv`, and `nyct2020.geojson`

### 5. Execute SQL Scripts

* Run SQL files in `PostGIS_Queries/` using QGIS DB Manager

### 6. Visualize Results

* Use QGIS project file: `QGIS_Project/spatio_temporal_analysis.qgs`
* Run Python visualizations: `python scripts/visualization.py`

---

## 💼 Folder Structure

```
.
├── Data/
│   ├── Raw/                # Original input files
│   ├── Processed/          # CSV output from SQL queries
├── PostGIS_Queries/        # SQL scripts for each analysis step
├── QGIS_Project/           # Ready-to-use QGIS file
├── Data_Visualization/     # Python plots from SQL outputs
├── Docs/                   # Project explanation and methodology
├── requirements.txt        # Python packages list
```

---

## 🚀 Project Outcomes

* Mapped and understood NYC rush hour bike demand distribution
* Combined census data with station-level trip data for tract-level insights
* Identified peak hours and busiest stations
* Proposed buffer-based bike repositioning strategy
* Created visual outputs for use in presentations or dashboards

---

## 👤 Author

**Prachi Sarode**
Cartographer & GIS Analyst | Spatial Data Science Enthusiast
[LinkedIn](https://www.linkedin.com/in/prachisarode95)

---

> This project follows and builds upon the LinkedIn Learning course "PostgreSQL: Spatial Data Science Project," applying the principles in a hands-on geospatial analytics workflow for portfolio development.

**Conclusion:**

This project utilizes PostgreSQL with PostGIS to analyze New York City bike-share data. PostGIS extends PostgreSQL's capabilities to handle geospatial data, allowing us to store bike station locations as points and census tracts as polygons. This enables spatial queries for grouping trip data geographically by identifying bike station types within each census tract. PostgreSQL's scalability and robust SQL support are essential for managing large datasets and performing complex spatial analyses, addressing real-world optimization challenges like citywide bike availability. We will use QGIS, an open-source tool, to visualize geospatial data and patterns, creating animations to illustrate trip pattern evolution. The workflow involves loading bike, trip, and station data into PostgreSQL, performing spatial analysis with SQL and PostGIS, and leveraging QGIS for data interaction and visualization. Python, with Pandas and Matplotlib, will also be used for further data visualization based on SQL query results. This hands-on experience is crucial for tackling large-scale data and geospatial challenges.

#  🚴 NYC Rush Hour Bike Demand Analysis using PostGIS

Based on the LinkedIn Learning course ["Hands-On PostgreSQL Project: Spatial Data Science"](https://www.linkedin.com/learning/hands-on-postgresql-project-spatial-data-science), this project applies advanced spatio-temporal analysis and geospatial visualization techniques to a synthetic but realistic urban dataset. It showcases proficiency in spatial SQL, geospatial data modeling, interactive map creation, and Python-based spatial analytics—all essential for real-world geospatial workflows.

---

## Project Overview

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

## Exploration of US census data and NYC stations & trip data

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

* **Time Manager Plugin:** Animated choropleth maps showing trip count evolution.

[🎥 Watch video preview](https://github.com/user-attachments/assets/c84d7930-4373-4533-92cc-fbde3ea1ac22)

* **Python:** Additional bar plots and time series charts using Pandas & Matplotlib.

![Chart](https://github.com/user-attachments/assets/92d38bc1-800b-4215-a213-8737afc1149c)

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

**Conclusion:**

By harnessing PostgreSQL with PostGIS, this project delivers actionable insights from NYC bike‑share data mapping stations to census tracts and optimizing bike availability across neighborhoods. QGIS animations and Python visualizations bring spatial patterns to life, while robust SQL analyses tackle large‑scale geospatial challenges head‑on. The result is a data‑driven framework that informs smarter urban mobility solutions and demonstrates proficiency in end‑to‑end GIS workflows.

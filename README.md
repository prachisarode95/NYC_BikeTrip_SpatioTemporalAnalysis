# NYC Rush Hour Bike Demand Analysis with PostGIS

This project is about the analysis of spatio-temporal patterns in New York City bike trip data using QGIS, and PostgreSQL. The study focuses on leveraging the QGIS DB Manager plugin to run PostGIS queries and visualize the results directly within QGIS. 

**Project Overview:**

* **Data Review:** I reviewed the provided data, which aimed to understand bike demand patterns during rush hours in New York City.
* **Dataset Acquisition and Processing:** I utilized two primary datasets. The first, containing bike station information, consisted of two files: "Stations" (station ID, latitude, and longitude) and trip data (trip ID, start/end times, bike type, and start/end station IDs). By joining these files, I mapped each trip's geographical path, revealing station usage and spatial patterns. I focused on data from September 17, 2024, demonstrating a methodology applicable to various time frames and zones.
* **Census Tract Integration:** I incorporated the 2020 Census Tract Boundary File for New York City from the US Census Bureau. This dataset provided geometry columns defining borough boundaries, tract IDs, and other attributes.
* **Rationale for Census Tracts:** I strategically chose census tracts over other geographic boundaries (neighborhoods, block groups) for their standardized, statistically reliable approach to spatial analysis. Aggregating trips into census tracts allowed me to identify broader demand trends that station-level data alone could not reveal. This enabled a more accurate understanding of demand fluctuations across larger areas, aiding in strategic bike repositioning.
* **Spatial and Temporal Analysis:** I performed spatial and temporal analysis using SQL queries within PostGIS, and visualized the results using QGIS and Python. This allowed me to discover and display the patterns of bike usage during rush hour.
* **Visualization:** I created visualizations using Python to show the results of the SQL queries.

**Objectives:**

1. Import and manage NYC bike trip data in a PostgreSQL/PostGIS database.
2. Perform spatial and temporal analysis using SQL queries within the QGIS DB Manager.
3. Visualize the analysis results directly in QGIS, highlighting spatio-temporal patterns.
4. Create informative visualizations using Python based on the SQL query outputs.

**Exploration of US census data and NYC stations & trip data:**

This project analyzes New York City rush hour bike demand using New York City census tract boundary data and synthetic trip data.

1. The first dataset comprises bike station information and trip details. Two files provide station IDs, latitudes, and longitudes ("Stations") and individual trip data, including unique IDs, start/end times, bike type, and start/end station IDs. Joining these files allows mapping trip origins and destinations, revealing station usage and spatial patterns. This project focuses on September 17, 2024 data, but the methodology applies to other timeframes and locations.

2. The second key dataset is the US Census Bureau's 2020 Census Tract Boundary File for New York City, containing geometry columns defining borough boundaries, tract IDs, and other attributes. While bike station locations provide precise origin-destination points, aggregating trips by census tract reveals broader spatial demand trends obscured at the station level. This approach identifies demand fluctuations across larger areas, aiding strategic bike repositioning.

Census tracts were chosen over other geographic boundaries (e.g., neighborhoods, census block groups) because they offer a standardized, statistically reliable approach to analyzing city areas. Neighborhood definitions are less consistent and less suitable for precise data-driven analysis. Using census tracts ensures accuracy and compatibility with other datasets, facilitating informed decisions regarding bike supply and demand management.

**Tech Stack:**

* **QGIS:** Open-source Geographic Information System for visualization
* **PostGIS:** Spatial database extension for PostgreSQL, used within QGIS DB Manager.
* **PostgreSQL:** Database used to store and query spatial data.
* **Python (Pandas, Matplotlib):** For additional data visualization based on SQL query results.

**Setup and Installation:**

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/yourusername/NYC_BikeTrip_SpatioTemporalAnalysis.git](https://www.google.com/search?q=https://github.com/yourusername/NYC_BikeTrip_SpatioTemporalAnalysis.git)
    cd NYC_BikeTrip_SpatioTemporalAnalysis
    ```

2.  **Install PostgreSQL and PostGIS:**

    * Install PostgreSQL and PostGIS.
    * Create a database (e.g., `nyc_bike_trips`) and enable the PostGIS extension:

        ```sql
        CREATE DATABASE nyc_bike_trips;
        \c nyc_bike_trips;
        CREATE EXTENSION postgis;
        ```

3.  **Install QGIS:**

    * Install QGIS, ensuring that PostGIS is enabled in your PostgreSQL connection and the DB Manager Plugin is installed.

4.  **Load Data into PostGIS using QGIS DB Manager:**

    * Open QGIS and connect to the PostgreSQL database.
    * Use the DB Manager plugin to import the `Data/Raw/stations.csv` and `Data/Raw/trip_data.csv` into a PostgreSQL table and the `Data/Raw/nyct2020.geojson` data into a PostGIS table.

5.  **Run SQL Queries in QGIS DB Manager:**

    * Copy and paste the SQL queries from `PostGIS_Queries/1.sql` into the QGIS DB Manager query window.
    * Execute the queries and save the results as a CSV file (`Data/Processed/half_hour_starttime_count.csv`).

6.  **Open QGIS Project:**

    * Open `QGIS_Project/spatio_temporal_analysis.qgs` in QGIS.
    * Add the `half_hour_starttime.csv` as a layer to visualize the results.

7.  **Run Python Visualization Script (Optional):**

    * Create a virtual environment:

        ```bash
        python3 -m venv venv
        source venv/bin/activate  # On macOS/Linux
        venv\Scripts\activate  # On Windows
        ```

    * Install dependencies:

        ```bash
        pip install -r requirements.txt
        ```

    * Run the Python script:

        ```bash
        python scripts/visualization.py
        ```

**Conclusion:**

This project utilizes PostgreSQL with PostGIS to analyze New York City bike-share data. PostGIS extends PostgreSQL's capabilities to handle geospatial data, allowing us to store bike station locations as points and census tracts as polygons. This enables spatial queries for grouping trip data geographically by identifying bike station types within each census tract. PostgreSQL's scalability and robust SQL support are essential for managing large datasets and performing complex spatial analyses, addressing real-world optimization challenges like citywide bike availability. We will use QGIS, an open-source tool, to visualize geospatial data and patterns, creating animations to illustrate trip pattern evolution. The workflow involves loading bike, trip, and station data into PostgreSQL, performing spatial analysis with SQL and PostGIS, and leveraging QGIS for data interaction and visualization. Python, with Pandas and Matplotlib, will also be used for further data visualization based on SQL query results. This hands-on experience is crucial for tackling large-scale data and geospatial challenges.

**Usage Instructions:**

* **`requirements.txt`:** Contains minimal Python dependencies to run the script
* **`PostGIS_Queries`:** Contains the SQL queries used to analyze the bike trip data within QGIS DB Manager.
* **`Data/Raw`:** Contains raw data files (stations.csv, trip_data.csv, nyct2020.geojson).
* **`Data/Processed`:** Contains the results after executing SQL queries in QGIS DB Manager ensuring the columns are suitable for visualization (e.g., time intervals, counts, geometries).
* **`QGIS_Project`:** The QGIS project file, is pre-configured to visualize the analysis results.
* **`Data_Visualization`:** Contains a Python script for generating additional visualizations based on the processed data (CSV file).
* **`Docs`:** Contains detailed project workflow, focusing on the QGIS/PostGIS integration and explanation of the SQL queries and their purpose.

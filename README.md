# 1. NYC Bike Trip Spatio-Temporal Analysis (QGIS/PostGIS Focused)

This documents the analysis of spatio-temporal patterns in New York City bike trip data using QGIS, and PostgreSQL. The analysis focuses on leveraging the QGIS DB Manager plugin to run PostGIS queries and visualize the results directly within QGIS.

## Project Overview 

In this project, I addressed a real-world geospatial problem using spatial-temporal techniques. Imagine working in the data team at a major bike-share company in New York City, have being tasked with solving a pricing problem.

Every morning, residents from neighborhoods like the Upper East Side and Central Park West pick up bikes from local stations to commute to the Financial District. By midmorning, residential stations are empty while business district stations are full. This pattern reverses by the end of the day as commuters head home. The goal is to ensure bike availability when and where it's needed, a classic spatial-temporal imbalance in a two-sided marketplace. In this hands-on geospatial project, I will act as a data analyst, analyzing the spatial-temporal patterns of bike share rides in New York City to provide data-driven solutions for stakeholders.

To tackle this challenge, I will use synthetic trip data detailing where and when each trip started and ended, along with the census tract boundary file of New York City to quantify results. By aggregating trip data to the census tract level, I can analyze the number of bike trips starting in each area every half hour. This analysis will reveal key insights into neighborhood demand at specific times, helping the company reposition bikes proactively. Critical questions include: Where should we move bikes before rush hour to ensure availability? If we use company vans for bike relocation, how many bikes should each van carry, and which stations should they service?

By the end of this project, I will have a solid understanding of how to approach real-world problems using spatial data science. I aim to derive solutions that enhance the efficiency of the bike-sharing system, benefiting both riders and the company.

## This project aims to:

* Import and manage NYC bike trip data in a PostgreSQL/PostGIS database.
* Perform spatial and temporal analysis using SQL queries within the QGIS DB Manager.
* Visualize the analysis results directly in QGIS, highlighting spatio-temporal patterns.
* Create informative visualizations using Python based on the SQL query outputs.

## Data

The data used in this project is:
* US Census (GeoJSON)
* NYC Stations (CSV)
* NYC Trip (CSV)

## Exploring US census data and NYC stations & trip data

Let's review the data for this project, which aims to understand bike demand patterns during rush hours in New York City. I will use two key datasets: New York City census tract boundary data and Synthetic trip data. 

The first dataset, provided in two files, includes bike station information. The first file, "Stations," contains each station's ID, latitude, and longitude. The second file includes trip data, where each row represents a bike trip with details such as a unique ID, start and end times, bike type (electric or mechanical), and start and end station IDs. By joining this file with the bike station data, we can map each trip's geographical path, revealing insights into station usage and spatial patterns. For this project, I will focus on data from September 17, 2024, but the methods learned here can be applied to bike share data across various time frames and zones.

The second key dataset is the 2020 Census Tract Boundary File for New York City, provided by the US Census Bureau. Each row contains information about a census tract, including a geometry column defining the borough boundary, tract ID, and other attributes. You might wonder why census tract data is necessary when we already have precise bike station locations. While station-level data shows where trips start and end, analyzing only at that level can obscure broader trends. Grouping trips into census tracts allows us to aggregate data and identify spatial trends that individual stations may not reveal, helping us understand demand fluctuations across larger areas and strategically reposition bikes.

Why use census tracts instead of other geographic boundaries like neighborhoods or census block groups? Census tracts, designed by the US Census Bureau for statistical analysis, offer a consistent, standardized approach to studying different city areas. They provide detailed insights while maintaining statistical reliability. In contrast, neighborhoods are often defined for planning purposes and can vary significantly, making them less suitable for precise data-driven analysis. Using census tracts ensures our analysis is accurate and compatible with other datasets, enabling informed decisions about managing bike supply and demand throughout the city.


## Let's go over the tech stack that will power our spatial-temporal analysis.

* **QGIS:** Open-source Geographic Information System for visualization
* **PostGIS:** Spatial database extension for PostgreSQL, used within QGIS DB Manager.
* **PostgreSQL:** Database used to store and query spatial data.
* **Python (Pandas, Matplotlib):** For additional data visualization based on SQL query results.

PostgreSQL is a powerful open-source relational database management system, popular in data science and analytics for efficiently handling large datasets. Its extension, PostGIS, adds spatial capabilities, allowing PostgreSQL to store, index, and query geospatial data, effectively transforming a non-spatial database into one that supports both traditional and spatial data.

In this project, we will leverage PostGIS to store bike station locations as points and New York City census tracts as polygons. This setup enables spatial queries to identify which station types fall within each census tract, facilitating geographical grouping of trip data. Managing this data requires a cloud database with robust SQL capabilities for processing complex queries, making it a scalable solution to handle the large trip data volumes and spatial analyses needed to address real-world issues like optimizing bike availability citywide. 

I will use QGIS, an open-source tool that interacts with databases via the DB Manager Plugin, to visualize geospatial data, which helps identify data point locations and spatial patterns. This will aid in understanding trends, as I will create animations to showcase the evolution of bike-share trip patterns for stakeholders. Our workflow involves loading bike, trip, and station data into PostgreSQL, performing spatial analysis with SQL and PostGIS queries, and using QGIS for data interaction and visualization. This hands-on experience with large-scale data and geospatial challenges using PostgreSQL and PostGIS is crucial for our project. Additionally, I will employ Python with Pandas and Matplotlib for further data visualization based on SQL query results.

## Setup and Installation

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

## Usage

* **`requirements.txt`:** Contains minimal Python dependencies to run the script
* **`PostGIS_Queries/1.sql`:** Contains the SQL queries used to analyze the bike trip data within QGIS DB Manager.
* **`Data/Processed/half_hour_starttime_count.csv`:** Contains the results after executing SQL queries in QGIS DB Manager ensuring the columns are suitable for visualization (e.g., time intervals, counts, geometries).
* **`QGIS_Project/spatio_temporal_analysis.qgs`:** The QGIS project file, is pre-configured to visualize the analysis results.
* **`Data_Visualization/visualization.py`:** Python script for generating additional visualizations based on the `analysis_results.csv` file.
* **`Docs/report.md (Detailed Report)`:** Focuses on overall project workflow with Focus on the QGIS/PostGIS workflow, Show screenshots of your QGIS project and DB Manager queries, Explain the SQL queries and their purpose, Describe the visualization process in QGIS, Explain the python visualizations and why they were created.

## Final Result
<video src="https://github.com/user-attachments/assets/d20f7af8-2083-4a39-814f-51caa5fa1abe" controls width="640"></video>

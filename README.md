# Spotify SQL Project and Query Optimization 




## Project Overview

Project Title: SQL Data Analysis and Query Optimization

Database: SPOTIFY_SQL_PROJECT


This project involves analyzing a Spotify dataset with various attributes about tracks, albums, and artists using **SQL**. It covers an end-to-end process of normalizing a denormalized dataset, performing SQL queries of varying complexity (easy, medium, and advanced), and optimizing query performance. The primary goals of the project are to practice advanced SQL skills and generate valuable insights from the dataset.




```sql
-- create table
DROP TABLE IF EXISTS spotify;
CREATE TABLE spotify (
    artist VARCHAR(255),
    track VARCHAR(255),
    album VARCHAR(255),
    album_type VARCHAR(50),
    danceability FLOAT,
    energy FLOAT,
    loudness FLOAT,
    speechiness FLOAT,
    acousticness FLOAT,
    instrumentalness FLOAT,
    liveness FLOAT,
    valence FLOAT,
    tempo FLOAT,
    duration_min FLOAT,
    title VARCHAR(255),
    channel VARCHAR(255),
    views FLOAT,
    likes BIGINT,
    comments BIGINT,
    licensed BOOLEAN,
    official_video BOOLEAN,
    stream BIGINT,
    energy_liveness FLOAT,
    most_played_on VARCHAR(50)
);
```
## Project Steps

### 1. Data Exploration
Before diving into SQL, it’s important to understand the dataset thoroughly. The dataset contains attributes such as:
- `Artist`: The performer of the track.
- `Track`: The name of the song.
- `Album`: The album to which the track belongs.
- `Album_type`: The type of album (e.g., single or album).
- Various metrics such as `danceability`, `energy`, `loudness`, `tempo`, and more.

### 4. Querying the Data
After the data is inserted, various SQL queries can be written to explore and analyze the data. Queries are categorized into **easy**, **medium**, and **advanced** levels to help progressively develop SQL proficiency.

#### Easy Queries
- Simple data retrieval, filtering, and basic aggregations.
  
#### Medium Queries
- More complex queries involving grouping, aggregation functions, and joins.
  
#### Advanced Queries
- Nested subqueries, window functions, CTEs, and performance optimization.

### 5. Query Optimization
In advanced stages, the focus shifts to improving query performance. Some optimization strategies include:
- **Indexing**: Adding indexes on frequently queried columns.
- **Query Execution Plan**: Using `EXPLAIN ANALYZE` to review and refine query performance.
  
---

## 15 Practice Questions

### Easy Level
1. Retrieve the names of all tracks that have more than 1 billion streams.
```sql
SELECT
	*
FROM
	SPOTIFY
WHERE
	STREAM > 1000000000;
```

2. List all albums along with their respective artists.
```sql
SELECT DISTINCT
	ALBUM,
	ARTIST
FROM
	SPOTIFY
ORDER BY
	1;
```

3. Get the total number of comments for tracks where `licensed = TRUE`.
```sql
SELECT
	SUM(COMMENTS) AS TOTAL_COMMENTS
FROM
	SPOTIFY
WHERE
	LICENSED = 'true';
```

4. Find all tracks that belong to the album type `single`.
```sql
SELECT
	*
FROM
	SPOTIFY
WHERE
	ALBUM_TYPE = 'single';
```

5. Count the total number of tracks by each artist.
```sql
SELECT
	ARTIST,
	COUNT(*) AS TOTAL_NO_SONGS
FROM
	SPOTIFY
GROUP BY
	1
ORDER BY
	2 DESC;
```


### Medium Level

1. Calculate the average danceability of tracks in each album.
```sql
SELECT
	ALBUM,
	AVG(DANCEABILITY) AS AVG_DANCEABILITY
FROM
	SPOTIFY
GROUP BY
	1
ORDER BY
	2 DESC;
```

2. Find the top 5 tracks with the highest energy values.
```sql

SELECT
	TRACK,
	MAX(ENERGY) AS ENERGY
FROM
	SPOTIFY
GROUP BY
	1
ORDER BY
	2 DESC LIMIT
	5;
```

3. List all tracks along with their views and likes where `official_video = TRUE`.
```sql
SELECT
	TRACK,
	SUM(VIEWS) AS TOTAL_VIEWS,
	SUM(LIKES) AS TOTAL_LIKES
FROM
	SPOTIFY
WHERE
	OFFICIAL_VIDEO = 'true'
GROUP BY
	1
ORDER BY
	2 DESC;
```

4. For each album, calculate the total views of all associated tracks.
```sql
SELECT
	ALBUM,
	TRACK,
	SUM(VIEWS)
FROM
	SPOTIFY
GROUP BY
	1,
	2
ORDER By 3 DESC;
```

5. Retrieve the track names that have been streamed on Spotify more than YouTube.
```sql
SELECT
	*
FROM
	(
		SELECT
			TRACK,
			-- most played on
			COALESCE(
				SUM(
					CASE
						WHEN MOST_PLAYED_ON = 'Youtube' THEN STREAM
					END
				),
				0
			) AS STREAMED_ON_YOUTUBE,
			COALESCE(
				SUM(
					CASE
						WHEN MOST_PLAYED_ON = 'Spotify' THEN STREAM
					END
				),
				0
			) AS STREAMED_ON_SPOTIFY
		FROM
			SPOTIFY
		GROUP BY
			1
	) AS TQ
WHERE
	STREAMED_ON_SPOTIFY > STREAMED_ON_YOUTUBE
	AND STREAMED_ON_YOUTUBE <> 0;
```

### Advanced Level

1. Find the top 3 most-viewed tracks for each artist using window functions.
/*
each artists and total view for each track
track with highest view for each artist(we need top )
dense rank
cte and filder rank

```sql
WITH
	RANKING_ARTIST AS (
		SELECT
			ARTIST,
			TRACK,
			SUM(VIEWS) AS TOTAL_VIEWS,
			DENSE_RANK() OVER (
				PARTITION BY
					ARTIST
				ORDER BY
					SUM(VIEWS) DESC
			) AS RANK
		FROM
			SPOTIFY
		GROUP BY
			1,
			2
		ORDER BY
			1,
			3 DESC
	)
SELECT
	*
FROM
	RANKING_ARTIST
WHERE
	RANK <= 3;
```

1. Write a query to find tracks where the liveness score is above the average.
```sql
SELECT
	TRACK,
	ARTIST,
	LIVENESS
FROM
	SPOTIFY
WHERE
	LIVENESS > (
		SELECT
			AVG(LIVENESS)
		FROM
			SPOTIFY
	);
```

2. **Use a `WITH` clause to calculate the difference between the highest and lowest energy values for tracks in each album.**
```sql
WITH cte
AS
(SELECT 
	album,
	MAX(energy) as highest_energy,
	MIN(energy) as lowest_energery
FROM spotify
GROUP BY 1
)
SELECT 
	album,
	highest_energy - lowest_energery as energy_diff
FROM cte
ORDER BY 2 DESC
```
   
5. Find tracks where the energy-to-liveness ratio is greater than 1.2.
6. Calculate the cumulative sum of likes for tracks ordered by the number of views, using window functions.


Here’s an updated section for your **Spotify Advanced SQL Project and Query Optimization** README, focusing on the query optimization task you performed. You can include the specific screenshots and graphs as described.

---

## Query Optimization Technique 

To improve query performance, we carried out the following optimization process:

- **Initial Query Performance Analysis Using `EXPLAIN`**
    - We began by analyzing the performance of a query using the `EXPLAIN` function.
    - The query retrieved tracks based on the `artist` column, and the performance metrics were as follows:
        - Execution time (E.T.): **7 ms**
        - Planning time (P.T.): **0.17 ms**
    - Below is the **screenshot** of the `EXPLAIN` result before optimization:
      ![EXPLAIN Before Index](https://github.com/najirh/najirh-Spotify-Data-Analysis-using-SQL/blob/main/spotify_explain_before_index.png)

- **Index Creation on the `artist` Column**
    - To optimize the query performance, we created an index on the `artist` column. This ensures faster retrieval of rows where the artist is queried.
    - **SQL command** for creating the index:
      ```sql
      CREATE INDEX idx_artist ON spotify_tracks(artist);
      ```

- **Performance Analysis After Index Creation**
    

- **Graphical Performance Comparison**
  
This optimization shows how indexing can drastically reduce query time, improving the overall performance of our database operations in the Spotify project.
---

## Technology Stack
- **Database**: PostgreSQL
- **SQL Queries**: DDL, DML, Aggregations, Joins, Subqueries, Window Functions
- **Tools**: pgAdmin 4 (or any SQL editor), PostgreSQL (via Homebrew, Docker, or direct installation)

## How to Run the Project
1. Install PostgreSQL and pgAdmin (if not already installed).
2. Set up the database schema and tables using the provided normalization structure.
3. Insert the sample data into the respective tables.
4. Execute SQL queries to solve the listed problems.
5. Explore query optimization techniques for large datasets.





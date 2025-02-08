-- Create table
DROP TABLE IF EXISTS SPOTIFY;
CREATE TABLE SPOTIFY (
	ARTIST VARCHAR(255),
	TRACK VARCHAR(255),
	ALBUM VARCHAR(255),
	ALBUM_TYPE VARCHAR(50),
	DANCEABILITY FLOAT,
	ENERGY FLOAT,
	LOUDNESS FLOAT,
	SPEECHINESS FLOAT,
	ACOUSTICNESS FLOAT,
	INSTRUMENTALNESS FLOAT,
	LIVENESS FLOAT,
	VALENCE FLOAT,
	TEMPO FLOAT,
	DURATION_MIN FLOAT,
	TITLE VARCHAR(255),
	CHANNEL VARCHAR(255),
	VIEWS FLOAT,
	LIKES BIGINT,
	COMMENTS BIGINT,
	LICENSED BOOLEAN,
	OFFICIAL_VIDEO BOOLEAN,
	STREAM BIGINT,
	ENERGY_LIVENESS FLOAT,
	MOST_PLAYED_ON VARCHAR(50)
);

SELECT
	COUNT(*)
FROM
	SPOTIFY;
	

SELECT
	COUNT(DISTINCT ARTIST)
FROM
	SPOtify;
	

SELECT
	COUNT(DISTINCT ALBUM)
FROM
	SPOTIFY;

SELECT DISTINCT
	ALBUM_TYPE
FROM
	SPOTIFY;

SELECT
	MIN(DURATION_MIN)
FROM
	SPOTIFY;

SELECT
	*
FROM
	SPOTIFY
WHERE
	DURATION_MIN = 0;

DELETE FROM SPOTIFY
WHERE
	DURATION_MIN = 0;

SELECT DISTINCT
	MOST_PLAYED_ON FROM
	SPOTIFY;

-------------------------------------------
-- Data analysis - Easy Category 
-------------------------------------------

-- Q1. Retrieve the names of all tracks that have more than 1 billion streams.

SELECT
	*
FROM
	SPOTIFY
WHERE
	STREAM > 1000000000;


-- Q2. List all albums along with their respective artists.
SELECT DISTINCT
	ALBUM,
	ARTIST
FROM
	SPOTIFY
ORDER BY
	1;

-- Q3. Get the total number of comments for tracks where licensed = TRUE.
SELECT
	SUM(COMMENTS) AS TOTAL_COMMENTS
FROM
	SPOTIFY
WHERE
	LICENSED = 'true';

-- Q4. Find all tracks that belong to the album type single.

SELECT
	*
FROM
	SPOTIFY
WHERE
	ALBUM_TYPE = 'single';
	
-- Q5. Count the total number of tracks by each artist.
SELECT
	ARTIST,
	COUNT(*) AS TOTAL_NO_SONGS
FROM
	SPOTIFY
GROUP BY
	1
ORDER BY
	2 DESC;

----------------------------------
-- Medium Level questoins
----------------------------------

/*
Calculate the average danceability of tracks in each album.
Find the top 5 tracks with the highest energy values.
List all tracks along with their views and likes where official_video = TRUE.
For each album, calculate the total views of all associated tracks.
Retrieve the track names that have been streamed on Spotify more than YouTube.
*/

-- Q6. Calculate the average danceability of tracks in each album.

SELECT
	ALBUM,
	AVG(DANCEABILITY) AS AVG_DANCEABILITY
FROM
	SPOTIFY
GROUP BY
	1
ORDER BY
	2 DESC;
-- Q7. Find the top 5 tracks with the highest energy values.

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
-- Q8. List all tracks along with their views and likes where official_video = TRUE.

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
	2DESC;

-- Q9. For each album, calculate the total views of all associated tracks.
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

-- Q10. Retrieve the track names that have been streamed on Spotify more than YouTube.

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



/*
Advanced Level
Find the top 3 most-viewed tracks for each artist using window functions.
Write a query to find tracks where the liveness score is above the average.
Use a WITH clause to calculate the difference between the highest and lowest energy values for tracks in each album.

*/

-- Q11. Find the top 3 most-viewed tracks for each artist using window functions.
/*
each artists and total view for each track
track with highest view for each artist(we need top )
dense rank
cte and filder rank
*/


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

-- Q12. Write a query to find tracks where the liveness score is above the average.

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
	
-- Q13.  Retrieve the track names that have been streamed on Spotify more than YouTube.

-- use a with clause to calculate the difference between the highest and lowest energy values for tracks in each album
WITH
	CTE AS (
		SELECT
			ALBUM,
			MAX(ENERGY) AS HIGHEST_ENERGY,
			MIN(ENERGY) AS LOWEST_ENERGY
		FROM
			SPOTIFY
		GROUP BY
			1
	)
SELECT
	ALBUM,
	HIGHEST_ENERGY - LOWEST_ENERGY AS ENERGY_DIFFERENCE
FROM
	CTE;


explain analyze   -- et 5.197 ms  pt 0.067
select artist,track,views from spotify 
where artist = 'Gorillaz'
and most_played_on = 'Youtube'
order by stream 
desc
limit 25


create index artist_index on spotify  (artist)

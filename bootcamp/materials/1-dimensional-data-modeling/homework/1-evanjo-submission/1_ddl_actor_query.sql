-- 1. **DDL for `actors` table:** Create a DDL for an `actors` table with the following fields:
--     - `films`: An array of `struct` with the following fields:
-- 		- film: The name of the film.
-- 		- votes: The number of votes the film received.
-- 		- rating: The rating of the film.
-- 		- filmid: A unique identifier for each film.

--     - `quality_class`: This field represents an actor's performance quality, determined by the average rating of movies of their most recent year. It's categorized as follows:
-- 		- `star`: Average rating > 8.
-- 		- `good`: Average rating > 7 and ≤ 8.
-- 		- `average`: Average rating > 6 and ≤ 7.
-- 		- `bad`: Average rating ≤ 6.
--     - `is_active`: A BOOLEAN field that indicates whether an actor is currently active in the film industry (i.e., making films this year).

-- Notes:
-- I figure we needed actor_id, actor_name, year as well in the dim table. 
-- Then I assume we need the `year` column so we can incrementally load

DROP TABLE jonesevan00738872.actors;
CREATE TABLE jonesevan00738872.actors (
    actor_id VARCHAR,
    actor_name VARCHAR,
    current_year INTEGER,
    is_active BOOLEAN,
    quality_class VARCHAR,
    films ARRAY(
            ROW(
                film VARCHAR,
                votes INTEGER,
                rating DOUBLE,
                film_id VARCHAR -- his query has filmid
                )
             )
)

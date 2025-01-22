INSERT INTO jonesevan00738872.actors

WITH last_year AS (
    SELECT
        actor_id,
        actor_name,
        current_year,
        films,
        quality_class,
        is_active
    FROM jonesevan00738872.actors
    WHERE current_year = 1969
),

-- do some preprocessing on this year's data in a CTE
-- we cannot avoid a group by here since we need the grain at the actor level
this_year AS (
    SELECT
        t.actor AS actor_name,
        t.actor_id,
        t.year,
        -- Aggregate films for today into an array of structs
        ARRAY_AGG(ROW(t.film, t.votes, t.rating, t.film_id)) AS films,
        -- Calculate the average rating for the actor in the current year
        AVG(t.rating) AS avg_rating
    FROM bootcamp.actor_films AS t
    WHERE t.year = 1970  -- The year to pull new films for the actor
    GROUP BY 1, 2, 3  -- Group by actor and actorid to aggregate films
)

SELECT
    -- things we dont expect to change we COALESCE
    COALESCE(ly.actor_id, ty.actor_id) AS actor_id,
    COALESCE(ly.actor_name, ty.actor_name) AS actor_name,

    -- Increment current year based on the most recent year
    -- You can't simply rely on ty.current_year because they might have not been active
    -- in that year but you still want your table to be cumulative
    COALESCE(ty.year, ly.current_year + 1) AS current_year,
    ty.actor_id IS NOT NULL AS is_active,

    -- let's assume quality_class is the avg() rating for all movies of current_year OR if 
    -- there were no movies this year we simply carry forward what our score was from last year 
    -- (which could also have been a carry forward)
    CASE
        WHEN ty.avg_rating > 8 THEN 'star'
        WHEN ty.avg_rating > 7 AND ty.avg_rating <= 8 THEN 'good'
        WHEN ty.avg_rating > 6 AND ty.avg_rating <= 7 THEN 'average'
        WHEN ty.avg_rating <= 6 THEN 'bad'
    END AS quality_class,

    -- We want to have an array of structs representing {metadata k/v} for each movie they ever made at the actor grain
    CASE
        -- if they're not active, carry forward history only
        WHEN ty.films IS NULL THEN ly.films
        -- if they're active for the first time ever
        WHEN ty.films IS NOT NULL AND ly.films IS NULL THEN ty.films
        -- if active last year and this year we need to concat
        WHEN ty.films IS NOT NULL AND ly.films IS NOT NULL
            THEN ty.films || ly.films -- we reverse load them in 
    END AS films
FROM last_year AS ly
FULL OUTER JOIN this_year AS ty ON ly.actor_id = ty.actor_id

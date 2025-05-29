P1: La calificación máxima de todas las películas.
------------------------------------------------------
SELECT MAX(calificacion)
FROM pelicula;

SELECT calificacion
FROM pelicula
ORDER BY calificacion DESC
LIMIT 1;

------------------------------------------------------

P2: El año más reciente con al menos una película con calificación superior a 9,0
------------------------------------------------------------------------------
/* Solo funciona para PostgreSQL */
SELECT anho
FROM pelicula
GROUP BY anho
HAVING BOOL_OR(calificacion > 9.0)
ORDER BY anho DESC
LIMIT 1;

SELECT MAX(anho)
FROM (
    SELECT *
    FROM pelicula
    WHERE calificacion > 9
) p;

SELECT MAX(anho)
FROM pelicula
WHERE calificacion > 9;

------------------------------------------------------

P3: Las películas con la mejor calificación (devolviendo empates)
-------------------------------------------------------------
SELECT nombre, anho
FROM pelicula
WHERE calificacion = (
    SELECT MAX(calificacion)
    FROM pelicula
);

------------------------------------------------------

P4: Cada película y su número de actores únicos
------------------------------------------------
SELECT p_nombre, p_anho, COUNT(DISTINCT a_nombre) AS actores
FROM personaje
GROUP BY p_nombre, p_anho;

------------------------------------------------------

P5: Los años en los que todas las películas tuvieron una calificación superior a 8,4 y el conteo de las películas para ese año
-------------------------------------------------------------------------------------------------
SELECT anho, COUNT(*) AS pelis
FROM pelicula
GROUP BY anho
HAVING EVERY(calificacion > 8.4);

------------------------------------------------------

P6: El número promedio de películas de todos los años (solo hay que considerar los años con al menos una película)
-------------------------------------------------------------------------------------------------------
/* Num promedio de todas las peliculas registradas en la database */
SELECT AVG(pelis) AS promedio_pelis
FROM (
    SELECT anho, COUNT(*) AS total_pelis
    FROM pelicula
    GROUP BY anho
) films_por_anho;

------------------------------------------------------

P7: Los años que tengan un número de películas mayor que el número promedio por año (solo hay que considerar los años con al menos una película)
-------------------------------------------------------------------------------------------------------------------------------------
/* No hemos visto ni trabajado con WITH 
pero lo uso para hacer un poco más legible la query principal */
WITH films_por_anho AS (
    SELECT anho, COUNT(*) AS total_pelis
    FROM pelicula
    GROUP BY anho
),
promedio AS (
    SELECT AVG(total_pelis) AS promedio_pelis
    FROM films_por_anho
)

SELECT DISTINCT anho
FROM films_por_anho, promedio
WHERE total_pelis > promedio_pelis;

------------------------------------------------------

P8: Los actores junto con el año de su primera película, el año de su segunda película y el año de su última película. Los años pueden ser iguales. En el caso de no haber participado en al menos dos películas, el año de la segunda película debe ser nulo
---------------------------------------------------------
SELECT DISTINCT a_nombre, 
    FIRST_VALUE(p_anho) OVER (
        PARTITION BY a_nombre 
        ORDER BY p_anho
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS primero, 
    NTH_VALUE(p_anho, 2) OVER (
        PARTITION BY a_nombre 
        ORDER BY p_anho
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS segundo, 
    LAST_VALUE(p_anho) OVER (
        PARTITION BY a_nombre 
        ORDER BY p_anho
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS ultimo
FROM personaje
ORDER BY a_nombre;

SELECT a_nombre, p_anho
FROM personaje
WHERE p_anho IN (
    SELECT p_anho
    FROM personaje
    ORDER BY p_anho DESC
    LIMIT 2
    UNION ALL
    SELECT p_anho
    FROM personaje
    ORDER BY p_anho
    LIMIT 1
);

SELECT a_nombre, p_anho
FROM (
    SELECT a_nombre, p_anho,
        ROW_NUMBER() OVER (PARTITION BY a_nombre ORDER BY p_anho ASC) AS orden,
        MAX(p_anho) AS ultima
    FROM personaje
) AS primeras
WHERE orden <= 2

UNION ALL

SELECT p.a_nombre, MAX(p.p_anho) AS p_anho
FROM personaje p
GROUP BY p.a_nombre;

------------------------------------------------------

P9: Las películas en el cuartil más alto con respecto a su número de actores distintos (debe devolver las películas con más actores)
--------------------------------------------------------------------------------------------------------------------------------
SELECT p_nombre, p_anho
FROM (
    SELECT *, NTILE(4) OVER (ORDER BY actores) AS cuartil
    FROM (
        -- Usamos la query de la P4
        SELECT p_nombre, p_anho, COUNT(DISTINCT a_nombre) AS actores
        FROM personaje
        GROUP BY p_nombre, p_anho
    ) AS actores_unicos
) AS peliculas_con_cuartiles
WHERE cuartil = 4;

------------------------------------------------------

P10: Las películas con un número de actrices únicas menor que el promedio de este número sobre todas las películas. En el caso de no haber ninguna actriz, debe incluir la película en el promedio con un conteo de 0 (y en los resultados finales)
------------------------------------------------------------------------------------------------------------------------------------------------------------------------
WITH pelicula_actor AS (
    SELECT DISTINCT p_nombre, p_anho, a_nombre, genero
    FROM personaje
    JOIN actor ON a_nombre = nombre
), 
promedio_actrices AS (
    SELECT AVG(actrices_por_pelicula) AS promedio
    FROM (
        -- Usamos la función FILTER para poder hacer el conteo por genero
        SELECT COUNT(DISTINCT a_nombre) FILTER (WHERE genero = 'F') AS actrices_por_pelicula
        FROM pelicula_actor
        GROUP BY p_nombre, p_anho
    ) AS p
)

SELECT p_nombre, p_anho
FROM (
    SELECT p_nombre, p_anho,
           COUNT(DISTINCT a_nombre) FILTER (WHERE genero = 'F') AS actrices
    FROM pelicula_actor
    GROUP BY p_nombre, p_anho
) AS peliculas_con_actrices, promedio_actrices
WHERE actrices < promedio;
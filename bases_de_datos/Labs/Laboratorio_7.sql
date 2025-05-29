-- P1
/* a) Consulta, tiempo de ejecución y numero de tuplas
    tiempo de ejecución: ~7464.513 ms (7.5s)
    numero de tuplas: 640573
*/
EXPLAIN ANALYZE
WITH tuplas AS (
    SELECT 
        p1.p_nombre AS n1,
        p1.p_anho AS a1,
        p2.p_nombre AS n2,
        p2.p_anho AS a2,
        p1.a_nombre AS actor
    FROM cine.personaje p1, cine.personaje p2
    WHERE p1.a_nombre = p2.a_nombre
)
SELECT n1, a1, n2, a2, COUNT(DISTINCT actor) AS k
FROM tuplas
WHERE n1 < n2 OR (n1 = n2 AND a1 < a2)
GROUP BY n1, a1, n2, a2
HAVING COUNT(DISTINCT actor) > 0;

/* b) Crear una vista que contenga el resultado de la consulta, el tiempo de ejecución y el número de tuplas
    tiempo de ejecución: 6992.018 ms (6.9s)
    numero de tuplas: 640573
*/
CREATE VIEW eval.arrova_pelis AS
WITH tuplas AS (
    SELECT 
        p1.p_nombre AS n1,
        p1.p_anho AS a1,
        p2.p_nombre AS n2,
        p2.p_anho AS a2,
        p1.a_nombre AS actor
    FROM cine.personaje p1, cine.personaje p2
    WHERE p1.a_nombre = p2.a_nombre
)
SELECT n1, a1, n2, a2, COUNT(DISTINCT actor) AS k
FROM tuplas
WHERE n1 < n2 OR (n1 = n2 AND a1 < a2)
GROUP BY n1, a1, n2, a2
HAVING COUNT(DISTINCT actor) > 0;

EXPLAIN ANALYZE
SELECT * FROM eval.arrova_pelis;

/* c) Crear una vista materializada que contenga el resultado de la consulta, el tiempo de ejecución y el número de tuplas
    tiempo de ejecución: 922.361 ms (0.9s)
    numero de tuplas: 640573
*/
CREATE MATERIALIZED VIEW eval.arrova_pelis_m AS
WITH tuplas AS (
    SELECT 
        p1.p_nombre AS n1,
        p1.p_anho AS a1,
        p2.p_nombre AS n2,
        p2.p_anho AS a2,
        p1.a_nombre AS actor
    FROM cine.personaje p1, cine.personaje p2
    WHERE p1.a_nombre = p2.a_nombre
)
SELECT n1, a1, n2, a2, COUNT(DISTINCT actor) AS k
FROM tuplas
WHERE n1 < n2 OR (n1 = n2 AND a1 < a2)
GROUP BY n1, a1, n2, a2
HAVING COUNT(DISTINCT actor) > 0;

EXPLAIN ANALYZE
SELECT * FROM eval.arrova_pelis_m;

-----------------------------------------------------------------------------
-- P2
/* a) Consulta, tiempo de ejecución y numero de tuplas
    tiempo de ejecución: 4.839 ms
    numero de tuplas: 7
*/
EXPLAIN ANALYZE
SELECT p.p_nombre n, p.p_anho a, COUNT(DISTINCT p.a_nombre) k
FROM cine.personaje p, cine.personaje br
WHERE br.p_nombre = 'Brazil'
    AND br.p_anho = 1985
    AND p.a_nombre = br.a_nombre
    AND (p.p_nombre != 'Brazil' OR p.p_anho != 1985)
GROUP BY p.p_nombre, p.p_anho
HAVING COUNT(DISTINCT p.a_nombre) >= 3;

/* b) Consultar el resultado de la consulta anterior con la vista creada en el punto P1.b), tiempo de ejecución y número de tuplas
    tiempo de ejecución: 8.848 ms
    numero de tuplas: 7
*/
EXPLAIN ANALYZE
SELECT * FROM eval.arrova_pelis
WHERE n1 = 'Brazil' AND a1 = 1985 AND k >= 3
UNION
SELECT * FROM eval.arrova_pelis
WHERE n2 = 'Brazil' AND a2 = 1985 AND k >= 3;

/* c) Consultar el resultado de la consulta anterior con la vista creada en el punto P1.c), tiempo de ejecución y número de tuplas
    tiempo de ejecución: 105.974 ms (0.1s)
    tiempo de ejecución post index: 49.833 ms (0.05s)
    numero de tuplas: 7
*/
CREATE INDEX idx_personaje_nombre_anho ON eval.arrova_pelis_m(n1, a1);
EXPLAIN ANALYZE
SELECT * FROM eval.arrova_pelis_m
WHERE n1 = 'Brazil' AND a1 = 1985 AND k >= 3
UNION
SELECT * FROM eval.arrova_pelis_m
WHERE n2 = 'Brazil' AND a2 = 1985 AND k >= 3;

-----------------------------------------------------------------------------
-- P3
-- a) Agregar dos evaluaciones a dos películas distintas de mi elección
INSERT INTO eval.resenha(g_nombre, p_nombre, p_anho, opinion, eval) VALUES
('arrova', 'The Lego Movie', 2014, 'Muy wena peli', 8.5),
('arrova', 'My Name Is Khan', 2010, 'Recomendada para ver en familia y sensibilizarse a estas temáticas', 9.0);

-- b) Crear una vista y vista materializada que contenga todas las evaluaciones de las películas que evalué
CREATE VIEW eval.arrova_resenhas AS
SELECT *
FROM eval.resenha
WHERE p_nombre IN (
    SELECT p_nombre
    FROM cine.pelicula
    WHERE g_nombre = 'arrova'
);

CREATE MATERIALIZED VIEW eval.arrova_resenhas_m AS
SELECT *
FROM eval.resenha
WHERE p_nombre IN (
    SELECT p_nombre
    FROM eval.resenha
    WHERE g_nombre = 'arrova'
);

-- c) Agregar otras dos evaluaciones de dos películas distintas de mi elección
INSERT INTO eval.resenha(g_nombre, p_nombre, p_anho, opinion, eval) VALUES
('arrova', 'Oldboy', 2013, 'Peli bizarra', 6.5),
('arrova', 'Zathura: A Space Adventure', 2005, 'Zathura >>> Jumanji', 7);

/* d) ¿Las vistas son iguales?
   No lo son puesto que la vista materializada tiene almacenada los datos previos a las últimas inserciones, en cambio como la vista
   tiene la lógica de nuestra consulta, siempre estará actualizada al momento de llamarla.
*/

/* e) Refresca la vista materializada ¿Ahora las vistas son iguales?
   Lo son puesto que la vista materializada ahora tiene almacenada los datos de nuestra última inserción.
*/
REFRESH MATERIALIZED VIEW eval.arrova_resenhas_m;

-- f) Crear un trigger y su stored procedure para refrescar la vista materializada solo cuando haya una actualización/inserción relevante para la vista, es decir, cuando se inserte una evaluación de una película que ya haya sido evaluada por mí.
CREATE OR REPLACE FUNCTION update_arrova_pelis()
RETURNS TRIGGER AS $$
BEGIN
    IF EXISTS (
        SELECT 1
        FROM eval.resenha
        WHERE g_nombre = 'arrova' AND p_nombre = NEW.p_nombre
    ) THEN
        REFRESH MATERIALIZED VIEW eval.arrova_resenhas_m;
    END IF;

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_arrova_pelis
AFTER INSERT OR UPDATE ON eval.resenha
FOR EACH ROW EXECUTE FUNCTION update_arrova_pelis();
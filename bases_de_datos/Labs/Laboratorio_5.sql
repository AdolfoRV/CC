-- P1
SELECT *
FROM cinelegado.cine C1, cinelegado.cine C2
WHERE C1.actor = C2.actor AND C1.genero <> C2.genero;

SELECT *
FROM cinelegado.cine R1, cinelegado.cine R2
WHERE R1.nombre = R2.nombre AND R1.anho = R2.anho AND (
      R1.calificacion <> R2.calificacion OR
      R1.estudio <> R2.estudio OR
      R1.ciudad <> R2.ciudad
    );

/* P2
La tabla solo se encuentra en 1NF, puesto que hay dependencias funcionales parciales, es decir,
con el atributo actor (subatributo de la llave primaria) podemos obtener el género, lo mismo con DF2
por lo que viola el hecho de que cada atributo no clave de una tabla dependa únicamente de la clave primaria
 */

-- P3
CREATE TABLE bcnf_df1 (
    actor TEXT PRIMARY KEY,
    genero TEXT
);

CREATE TABLE bcnf_df2 (
    nombre TEXT,
    anho INT,
    calificacion INT,
    estudio TEXT,
    ciudad TEXT,
    PRIMARY KEY (nombre, anho)
);

CREATE TABLE bcnf_personaje (
    nombre TEXT,
    anho INT,
    actor TEXT,
    personaje TEXT,
    PRIMARY KEY (nombre, anho, actor, personaje),
    FOREIGN KEY (actor) REFERENCES bcnf_df1(actor),
    FOREIGN KEY (nombre, anho) REFERENCES bcnf_df2(nombre, anho)
);

-- P4
INSERT INTO bcnf_df1 (actor, genero)
SELECT DISTINCT actor, genero
FROM cinelegado.cine;

INSERT INTO bcnf_df2 (nombre, anho, calificacion, estudio, ciudad)
SELECT DISTINCT nombre, anho, calificacion, estudio, ciudad
FROM cinelegado.cine;

INSERT INTO bcnf_personaje (nombre, anho, actor, personaje)
SELECT DISTINCT nombre, anho, actor, personaje
FROM cinelegado.cine;

/* P5
Ahora la tabla solo se encuentra en 2NF, puesto que hay dependencia transitiva, es decir,
con el atributo estudio (el cual depende de la llave primaria de la tabla bcnf_df2) podemos obtener la ciudad
por lo que viola el hecho de que no pueden existir dependencias transitivas
 */

-- P6
CREATE TABLE bcnf_df3 (
    estudio TEXT PRIMARY KEY,
    ciudad TEXT
);

ALTER TABLE bcnf_df2
DROP COLUMN ciudad;
ALTER TABLE bcnf_df2
DROP COLUMN estudio;
-- P1
CREATE TABLE eleccion.arrova_estado (
    nombre VARCHAR(255) PRIMARY KEY,
    voto_electoral SMALLINT,
    cierre TIME,
    num_candidatos SMALLINT
);

INSERT INTO eleccion.arrova_estado SELECT * FROM eleccion.estado;

CREATE TABLE eleccion.arrova_condado (
    nombre VARCHAR(255),
    estado VARCHAR(255),
    reportado FLOAT CHECK (reportado >= 0 AND reportado <= 1),
    PRIMARY KEY (nombre, estado),
    FOREIGN KEY (estado) REFERENCES eleccion.arrova_estado(nombre)
);

INSERT INTO eleccion.arrova_condado SELECT * FROM eleccion.condado;

CREATE TABLE eleccion.arrova_candidato (
    nombre VARCHAR(255) PRIMARY KEY,
    partido VARCHAR(255)
);

INSERT INTO eleccion.arrova_candidato SELECT * FROM eleccion.candidato;

CREATE TABLE eleccion.arrova_votosPorCondado (
    candidato VARCHAR(255),
    condado VARCHAR(255),
    estado VARCHAR(255),
    votos INT,
    PRIMARY KEY (candidato, condado, estado),
    FOREIGN KEY (candidato) REFERENCES eleccion.arrova_candidato(nombre),
    FOREIGN KEY (condado, estado) REFERENCES eleccion.arrova_condado(nombre, estado)
);

INSERT INTO eleccion.arrova_votosPorCondado SELECT * FROM eleccion.votosPorCondado;

-- P2
UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado1 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

-- P3

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado1 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

-- P4
START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado2 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado2 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

-- P5
START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado3 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado3 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado4 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado4 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado5 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado5 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado6 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado6 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado7 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado7 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado8 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado8 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondado9 AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condado9 AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

-- P6
START TRANSACTION;

UPDATE eleccion.arrova_votosPorCondado AS g
SET votos = v.votos
FROM eleccion.votosPorCondadoX AS v
WHERE g.candidato = v.candidato
  AND g.condado = v.condado
  AND g.estado = v.estado;

UPDATE eleccion.arrova_condado AS g
SET reportado = v.reportado
FROM eleccion.condadoX AS v
WHERE g.nombre = v.nombre
  AND g.estado = v.estado;

COMMIT;

/* Esta consulta debería encontrarse vacía dado que se rechazó la inyección de SQL, esto porque pusieron valores mayores a 1 en reportado,
  lo que rompía la regla ya mencionada, luego al ser atómico y por consistencia (respetar las reglas de integridad/constrains), nada se guardó
*/
SELECT *
FROM eleccion.arrova_condado
WHERE reportado > 1;
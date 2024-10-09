CREATE DATABASE projects;

SELECT * FROM bicing;

# Cambiamos nombre de columnas
ALTER TABLE bicing
CHANGE `ï»¿Fecha inicio` `fecha_inicio` text;

ALTER TABLE bicing
CHANGE `Fecha fin` `fecha_fin` text;

ALTER TABLE bicing
CHANGE `MatrÃ­cula` matricula text;

DESCRIBE bicing;

# Convertimos valores de tipo text a datetime
## 1) añadimos una columna temporal datetime
ALTER table bicing
ADD COLUMN inicio datetime,
ADD COLUMN fin datetime;

## 2) Convertimos valores text a datetime
SET SQL_SAFE_UPDATES = 0;

UPDATE bicing
SET inicio = str_to_date(fecha_inicio, '%d/%m/%Y %H:%i:%s');

UPDATE bicing
SET fin = str_to_date(fecha_fin, '%d/%m/%Y %H:%i:%s');

## 3) Verificamos los cambios:
SELECT fecha_inicio, fecha_fin, inicio, fin
FROM bicing;

## 4) Eliminamos las columnas originales
ALTER TABLE bicing
DROP COLUMN fecha_inicio,
DROP COLUMN fecha_fin;

SET SQL_SAFE_UPDATES = 1;

----------------------------------------------------------------------------------
# Cantidad de viajes en el período:
SELECT COUNT(*) AS cant_viajes
FROM bicing;

# Duración promedio:
SELECT ROUND(AVG(minutos),2) AS avg_minutos 
FROM bicing;

# Duracion total por dia
SELECT DAY(inicio) as dia, SUM(minutos) AS total_min_dia
FROM bicing
group by dia
ORDER BY dia;

# Gasto total
SELECT ROUND(SUM(Importe),2) AS gasto_total
FROM bicing;

# Gasto € diario
SELECT DAY(inicio) as dia, ROUND(SUM(importe),2) gasto_diario
FROM bicing
group by dia
ORDER BY dia;

# Dias que no se usó el bicing
SELECT (max(day(inicio))-min(day(fin))) - COUNT(DISTINCT DAY(inicio)) AS dias_no_usados
FROM bicing;

# Ratio de eléctricas y mecánicas
WITH t AS (
SELECT *, 
CASE WHEN importe !=0 THEN 'electrica' ELSE 'mecanica' END AS tipo_bici
FROM bicing)
SELECT round((SELECT COUNT(tipo_bici) FROM t WHERE tipo_bici = 'electrica')/count(*)*100,2) AS ratio_electrica,
	   round((SELECT COUNT(tipo_bici) FROM t WHERE tipo_bici = 'mecanica')/count(*)*100,2) AS ratio_mecanica
FROM t;

# Repetición de bicis?
SELECT matricula, COUNT(*)
FROM bicing
GROUP BY matricula
HAVING COUNT(*) > 1;






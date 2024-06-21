-- Primero, eliminar los triggers y procedimientos almacenados
DROP TRIGGER IF EXISTS before_insert_convocatoria;
DROP TRIGGER IF EXISTS before_insert_catalogo_carreras;
DROP TRIGGER IF EXISTS before_insert_opciones_carrera;

DROP PROCEDURE IF EXISTS completar_registro;

-- Luego, eliminar las tablas con sus constraints
DROP TABLE IF EXISTS registro_examen;
DROP TABLE IF EXISTS opciones_carrera;
DROP TABLE IF EXISTS catalogo_carreras;
DROP TABLE IF EXISTS costos_examen;
DROP TABLE IF EXISTS convocatorias;
DROP TABLE IF EXISTS aspirantes;

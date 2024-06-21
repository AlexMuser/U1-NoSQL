
-- Aspirante con correo válido y CURP válido
INSERT INTO aspirantes (nombre, correo, curp)
VALUES 
    ('Laura González', 'laura@gmail.com', 'GOGL950518MDFXXX08'),
    ('Eduardo Pérez', 'eduardo@hotmail.com', 'PEME910625HDFXXX02'),
    ('Ana Gómez', 'ana@outlook.com', 'GOAM880805MDFXXX01');

-- CURP con formato incorrecto
INSERT INTO aspirantes (nombre, correo, curp)
VALUES ('Ana Martínez', 'ana@gmail.com', 'MARA123456MEXABC01');

-- Convocatorias válidas con fechas correctas
INSERT INTO convocatorias (anio, numero_convocatoria, fecha_inicio, fecha_fin)
VALUES
    (2024, 1, '2024-07-01', '2024-07-15'),
    (2024, 2, '2024-08-01', '2024-08-15');


-- Más de dos convocatorias en el mismo año
INSERT INTO convocatorias (anio, numero_convocatoria, fecha_inicio, fecha_fin)
VALUES (2024, 3, '2024-09-01', '2024-09-15');


-- Costos de examen válidos asociados a convocatorias existentes
INSERT INTO costos_examen (convocatoria_id, costo)
VALUES
    (1, 500.00),
    (2, 550.00);

-- Convocatoria_id no existente en la tabla convocatorias
INSERT INTO costos_examen (convocatoria_id, costo)
VALUES (3, 600.00);



-- Carreras válidas con estatus activo y fecha de alta correcta
INSERT INTO catalogo_carreras (nombre_carrera, estatus, fecha_alta)
VALUES
    ('Sistemas', 'activa', '2024-06-20'),
    ('TICs', 'activa', '2024-06-20'),
    ('Mecatrónica', 'activa', '2024-06-20'),
    ('Logística', 'activa', '2024-06-20'),
    ('Química', 'activa', '2024-06-20'),
    ('Electrónica', 'inactiva', '2024-06-20');


-- Opciones de carrera válidas asociadas a aspirantes, convocatorias y carreras existentes
INSERT INTO opciones_carrera (aspirante_id, convocatoria_id, carrera_id, prioridad)
VALUES
    (1, 1, 1, 1),  
    (1, 1, 2, 2),  
    (1, 1, 3, 3),  
    (2, 2, 1, 1),  
    (2, 2, 4, 2),  
    (3, 1, 3, 1),  
    (3, 2, 5, 1);

-- Prueba de inserción de carrera duplicada
INSERT INTO opciones_carrera (aspirante_id, convocatoria_id, carrera_id, prioridad)
VALUES (1, 1, 3, 4);

-- Prueba de inserción de prioridad duplicada
INSERT INTO opciones_carrera (aspirante_id, convocatoria_id, carrera_id, prioridad)
VALUES (1, 1, 4, 3);


-- Carrera_id correspondiente a una carrera inactiva en catalogo_carreras
INSERT INTO opciones_carrera (aspirante_id, convocatoria_id, carrera_id, prioridad)
VALUES (1, 1, 6, 1);  -- Suponiendo que el id_carrera 6 está inactiva o no existe

-- Prioridad fuera del rango permitido (1 a 3)
INSERT INTO opciones_carrera (aspirante_id, convocatoria_id, carrera_id, prioridad)
VALUES (2, 2, 2, 4);



-- Registro de examen válido asociado a aspirante y convocatoria existentes
INSERT INTO registro_examen (aspirante_id, convocatoria_id, token)
VALUES 
    (1, 1, 'ABC123'),
    (2, 2, 'DEF456'),
    (3, 2, 'GHI789');


-- Token duplicado
INSERT INTO registro_examen (aspirante_id, convocatoria_id, token)
VALUES (1, 1, 'ABC123');
INSERT INTO registro_examen (aspirante_id, convocatoria_id, token)
VALUES (2, 2, 'ABC123');
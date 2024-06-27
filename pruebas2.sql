
INSERT INTO catalogo_carreras (nombre_carrera, estatus, fecha_alta)
VALUES
    ('Sistemas', 'activa', '2024-06-20'),
    ('TICs', 'activa', '2024-06-20'),
    ('Mecatrónica', 'activa', '2024-06-20'),
    ('Logística', 'activa', '2024-06-20'),
    ('Química', 'activa', '2024-06-20'),
    ('Electrónica', 'inactiva', '2024-06-20');




-- Insertar valores en convocatorias

INSERT INTO convocatorias (id_convocatoria, anio, numero_convocatoria, fecha_inicio, fecha_fin, costo)
VALUES (1, 2024, 1, '2024-07-01', '2024-07-31', 100.00);

INSERT INTO convocatorias (id_convocatoria, anio, numero_convocatoria, fecha_inicio, fecha_fin, costo)
VALUES (2, 2024, 2, '2024-07-01', '2024-07-31', 100.00);


-- Intentar insertar una convocatoria con el mismo año y un numero_convocatoria que no sea 1 o 2
-- (DEBE TRONAR)
INSERT INTO convocatorias (anio, numero_convocatoria, fecha_inicio, fecha_fin, costo)
VALUES (2024, 3, '2024-07-01', '2024-07-31', 100.00);




-- Insertar valores en tokens_correos

INSERT INTO tokens_correos (id_token_correo, correo, curp, id_convocatoria) VALUES (1, 'noel@outlook.com', 'ABCD123456HCHLKN12', 1);
INSERT INTO tokens_correos (correo, curp, id_convocatoria) VALUES ('alfredo@outlook.com','ABCD123456HCHLKN12', 1);

-- Alfredo pide otro token
INSERT INTO tokens_correos (correo, curp, id_convocatoria) VALUES ('alfredo@outlook.com','ABCD123456HCHLKN12', 1);






-- Simulamos que el usuario qwerty ha validado el correo y completado el registro
UPDATE tokens_correos
SET correo_validado = 1
WHERE id_token_correo = 1;


CALL RegisterAspirante(1, "Noel", 1, 2, 3); 



-- Alfredo pide otro token (TRUENA PORQUE ESTA REGISTRADO EL MISMO CURP)
INSERT INTO tokens_correos (correo, curp, id_convocatoria) VALUES ('alfredo@outlook.com','ABCD123456HCHLKN12', 1);


-- Si noel quiere volver a pedir otro token con el mismo correo tampoco lo dejara 
INSERT INTO tokens_correos (correo, curp, id_convocatoria) VALUES ('noel@outlook.com','ABCD123456HCHLKN12', 1);



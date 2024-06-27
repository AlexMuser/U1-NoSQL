

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

INSERT INTO tokens_correos (id_token_correo, correo, convocatoria_id) VALUES (1, 'qwerty@outlook.com', 1);
INSERT INTO tokens_correos (id_token_correo, correo, convocatoria_id) VALUES (2, 'alfredo@outlook.com', 1);


-- Simulamos que el usuario qwerty ha validado el correo y completado el registro
UPDATE tokens_correos
SET registro_completado = 1, correo_validado = 1
WHERE id_token_correo = 1;


-- Intentamos que el usuario qwerty se registre de nuevo en la misma convocatoria 
-- (DEBE TRONAR)
INSERT INTO tokens_correos (correo, convocatoria_id) VALUES ('qwerty@outlook.com', 1);


-- Ahora lo registramos en otra convocatoria
INSERT INTO tokens_correos (id_token_correo, correo, convocatoria_id) VALUES (3, 'qwerty@outlook.com', 2);


-- Intentamos que el usuario qwerty genere mas tokens, sin haber completado el registro
INSERT INTO tokens_correos (id_token_correo, correo, convocatoria_id) VALUES (4, 'alfredo@outlook.com', 1);


-- Vemos como hay mas de un token para qwerty en la convocatoria 1
SELECT * FROM tokens_correos WHERE correo = 'alfredo@outlook.com';


-- Simulamos que el usuario qwerty ha ha validado el correo y completado el registro
UPDATE tokens_correos
SET registro_completado = 1, correo_validado = 1
WHERE id_token_correo = 4;


-- Intentamos que el usuario qwerty genere mas tokens, habiendo completado el registro 
-- (DEBE TRONAR)
INSERT INTO tokens_correos (correo, convocatoria_id) VALUES ('alfredo@outlook.com', 1);




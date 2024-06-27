

INSERT INTO catalogo_carreras (nombre_carrera, estatus, fecha_alta)
VALUES
    ('Sistemas', 'activa', '2024-06-20'),
    ('TICs', 'activa', '2024-06-20'),
    ('Mecatrónica', 'activa', '2024-06-20'),
    ('Logística', 'activa', '2024-06-20'),
    ('Química', 'activa', '2024-06-20'),
    ('Electrónica', 'inactiva', '2024-06-20');


    INSERT INTO convocatorias (id_convocatoria, anio, numero_convocatoria, fecha_inicio, fecha_fin, costo)
VALUES (1, 2024, 1, '2024-07-01', '2024-07-31', 100.00);

INSERT INTO convocatorias (id_convocatoria, anio, numero_convocatoria, fecha_inicio, fecha_fin, costo)
VALUES (2, 2024, 2, '2024-07-01', '2024-07-31', 100.00);



INSERT INTO tokens_correos (id_token_correo, correo, id_convocatoria) VALUES (1, 'qwerty@outlook.com', 1);
INSERT INTO tokens_correos (id_token_correo, correo, id_convocatoria) VALUES (2, 'alfredo@outlook.com', 1);
INSERT INTO tokens_correos (id_token_correo, correo, id_convocatoria) VALUES (3, 'alfredo@outlook.com', 2);
INSERT INTO tokens_correos (id_token_correo, correo, id_convocatoria) VALUES (4, 'qwerty@outlook.com', 2);

UPDATE tokens_correos
SET correo_validado = 1
WHERE id_token_correo = 1;


CALL RegisterAspirante(1, "Juan Perez", "ABCD123456HCHLKN12", 1, 2, 3); 
CALL RegisterAspirante(2, "Juan Perez", "ABCD123456HCHLKN13", 1, 2, 4); 
CALL RegisterAspirante(3, "Juan Perez", "ABCD123456HCHLKN13", 1, 2, 4);
CALL RegisterAspirante(4, "qwerty", "ABCD123456HCHLKN13", 1, 2, 4);
 
CALL RegisterAspirante(1, "Juan Perez", "ABCD123456HCHLKN12", 1, 2, 5); 



delete from opciones_carrera;
delete from aspirantes;






/*
    Punto 1
        Usar expresiones regulares para validar el correo y la curp
    
    Punto 2
        Crear una tabla para almacenar los costos de los exámenes asociados a las convocatorias
        No se pueden tener más de dos convocatorias por año

    Punto 3
        El usuario puede pedir los token que desee siempre y cuando este en PENDIENTE. Si esta en COMPLETO no se puede pedir token

    Punto 4
        Detalle en opciones de carrera porque le faltan reglas
*/

-- Crear la base de datos
-- 
CREATE DATABASE BD_Pruebas;

use BD_Pruebas;

CREATE TABLE aspirantes (
    id_aspirante INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    curp VARCHAR(18) NOT NULL
);

ALTER TABLE aspirantes
ADD CONSTRAINT UK_correo UNIQUE (correo),
ADD CONSTRAINT UK_curp UNIQUE (curp),
/*
    1)
    A continuaciòn se agregan las expresiones regulares para validar el correo y la curp
    el cual tiene como objetivo lo siguiente:
    - El correo debe cumplir con el formato de que comience con letras, números, puntos, guiones bajos, porcentajes y signos más o menos, seguido de un arroba, seguido de gmail, hotmail u outlook, seguido de un punto y dos letras.
    - La CURP debe cumplir con el formato de que comience con cuatro letras mayúsculas, seguido de seis números, seguido de una letra H o M, seguido de cinco letras mayúsculas y finalmente dos números.
*/
ADD CONSTRAINT CHK_correo CHECK (correo REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
ADD CONSTRAINT CHK_curp CHECK (curp REGEXP '^[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[0-9]{2}$');


CREATE TABLE convocatorias (
    id_convocatoria INT AUTO_INCREMENT PRIMARY KEY,
    anio INT NOT NULL,
    numero_convocatoria INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL
);

ALTER TABLE convocatorias
ADD CONSTRAINT UK_anio_numero UNIQUE (anio, numero_convocatoria);

/*
    2)
    A continuación se agrega un trigger que evita que se inserten más de dos convocatorias por año.
*/
DELIMITER //

CREATE TRIGGER before_insert_convocatoria
BEFORE INSERT ON convocatorias
FOR EACH ROW
BEGIN
    DECLARE convocatorias_count INT;

    SELECT COUNT(*)
    INTO convocatorias_count
    FROM convocatorias
    WHERE anio = NEW.anio;

    IF convocatorias_count >= 2 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se pueden crear más de dos convocatorias por año';
    END IF;
END//

DELIMITER ;


/*
    2)
    Se crea una tabla para almacenar los costos de los exámenes asociados a las convocatorias.
*/
CREATE TABLE costos_examen (
    id INT AUTO_INCREMENT PRIMARY KEY,
    convocatoria_id INT,
    costo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (convocatoria_id) REFERENCES convocatorias(id_convocatoria)
);

ALTER TABLE costos_examen
ADD CONSTRAINT CHK_costo CHECK (costo > 0);

CREATE TABLE catalogo_carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    estatus ENUM('activa', 'inactiva') NOT NULL DEFAULT 'activa',
    fecha_alta DATE NOT NULL DEFAULT CURRENT_DATE
);

ALTER TABLE catalogo_carreras
ADD CONSTRAINT UK_nombre_carrera UNIQUE (nombre_carrera);

/*
    4)
    Se crea un trigger que evita que se inserten carreras con una fecha de alta atrás de la fecha actual.
*/

DELIMITER //

CREATE TRIGGER before_insert_catalogo_carreras
BEFORE INSERT ON catalogo_carreras
FOR EACH ROW
BEGIN
    IF NEW.fecha_alta < CURRENT_DATE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede insertar un registro con una fecha de alta pasada';
    END IF;
END//

DELIMITER ;

CREATE TABLE opciones_carrera (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aspirante_id INT,
    convocatoria_id INT,
    carrera_id INT,
    prioridad INT NOT NULL,
    FOREIGN KEY (aspirante_id) REFERENCES aspirantes(id_aspirante),
    FOREIGN KEY (convocatoria_id) REFERENCES convocatorias(id_convocatoria),
    FOREIGN KEY (carrera_id) REFERENCES catalogo_carreras(id_carrera)
);

ALTER TABLE opciones_carrera
ADD CONSTRAINT CHK_prioridad CHECK (prioridad >= 1),
ADD CONSTRAINT UK_aspirante_convocatoria_prioridad UNIQUE (aspirante_id, convocatoria_id, prioridad),
ADD CONSTRAINT UK_aspirante_convocatoria_carrera UNIQUE (aspirante_id, convocatoria_id, carrera_id);

--Quiser usar un check pero me botaba este error, por eso implemente el siguiente Trigger

/*
    4) Trigger que evita que se inserten opciones de carrera con carreras inactivas.
*/
DELIMITER //

CREATE TRIGGER before_insert_opciones_carrera
BEFORE INSERT ON opciones_carrera
FOR EACH ROW
BEGIN
    DECLARE v_carrera_activa INT;

    -- Verificar si la carrera seleccionada está activa
    SELECT COUNT(*)
    INTO v_carrera_activa
    FROM catalogo_carreras
    WHERE id_carrera = NEW.carrera_id AND estatus = 'activa';


    IF v_carrera_activa = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede seleccionar una carrera inactiva';
    END IF;
END//

DELIMITER ;


CREATE TABLE registro_examen (
    id_regexamen INT AUTO_INCREMENT PRIMARY KEY,
    aspirante_id INT,
    convocatoria_id INT,
    token VARCHAR(100) NOT NULL,
    fecha_solicitud TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estado ENUM('PENDIENTE', 'COMPLETADO') DEFAULT 'PENDIENTE',
    FOREIGN KEY (aspirante_id) REFERENCES aspirantes(id_aspirante),
    FOREIGN KEY (convocatoria_id) REFERENCES convocatorias(id_convocatoria)
);

ALTER TABLE registro_examen
ADD CONSTRAINT UK_aspirante_convocatoria UNIQUE (aspirante_id, convocatoria_id),
ADD CONSTRAINT UK_token UNIQUE (token);

/*No permite cambiar el estatus a completado, hasta que 
 el aspirante tenga seleccionadas sus tres opciones de carrera 
*/

DELIMITER //

CREATE PROCEDURE completar_registro(
    IN p_aspirante_id INT,
    IN p_convocatoria_id INT
)
BEGIN
    DECLARE v_cantidad_opciones INT DEFAULT 0;

    -- Verificamos que el aspirante haya seleccionado al menos tres opciones de carrera
    SELECT COUNT(*)
    INTO v_cantidad_opciones
    FROM opciones_carrera
    WHERE aspirante_id = p_aspirante_id AND convocatoria_id = p_convocatoria_id;

    -- Actualizar el estado a COMPLETADO
    IF v_cantidad_opciones >= 3 THEN
        UPDATE registro_examen
        SET estado = 'COMPLETADO'
        WHERE aspirante_id = p_aspirante_id AND convocatoria_id = p_convocatoria_id;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El aspirante debe seleccionar al menos tres opciones de carrera para completar el registro.';
    END IF;
END//

DELIMITER ;

-- Ejemplo de uso del procedimiento almacenado
-- CALL completar_registro(1, 1);
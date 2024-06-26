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
CREATE DATABASE BD_Pruebas;

USE BD_Pruebas;

-- Tabla para tokens de correos
CREATE TABLE tokens_correos (
    correo VARCHAR(100) NOT NULL PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    validado BOOLEAN DEFAULT FALSE,
    procesado BOOLEAN DEFAULT FALSE,
    CONSTRAINT CHK_correo CHECK (correo REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
) ENGINE=InnoDB;


-- Trigger para asegurar que el correo no se repita con validado y procesado en true
-- Y si ya existe un registro con el correo pero no esta validado o procesado, permitir la inserción pero antes eliminar el registro anterior
DELIMITER //

CREATE TRIGGER before_insert_tokens_correos
BEFORE INSERT ON tokens_correos
FOR EACH ROW
BEGIN
    DECLARE v_count INT;

    -- Verificar si el correo ya está registrado con validado y procesado en true
    SELECT COUNT(*)
    INTO v_count
    FROM tokens_correos
    WHERE correo = NEW.correo
      AND validado = TRUE
      AND procesado = TRUE;

    -- Si existe al menos un registro, no permitir la inserción y lanzar un error
    IF v_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este correo ya ha sido registrado para esta convocatoria';
    ELSE
        -- Eliminar el registro anterior
        DELETE FROM tokens_correos
        WHERE correo = NEW.correo;
    END IF;
END//

DELIMITER ;



-- Tabla convocatorias
CREATE TABLE convocatorias (
    id_convocatoria INT AUTO_INCREMENT PRIMARY KEY,
    anio INT NOT NULL,
    numero_convocatoria INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT UK_anio_numero UNIQUE (anio, numero_convocatoria),
    CONSTRAINT CHK_numero_convocatoria CHECK (numero_convocatoria IN (1, 2)),
    CONSTRAINT CHK_anio CHECK (anio > 0)
) ENGINE=InnoDB;

-- Tabla aspirantes
CREATE TABLE aspirantes (
    id_aspirante INT AUTO_INCREMENT PRIMARY KEY,
    id_convocatoria INT,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    curp VARCHAR(18) NOT NULL,
    CONSTRAINT UK_correo UNIQUE (correo),
    CONSTRAINT UK_curp UNIQUE (curp),
    CONSTRAINT CHK_correo CHECK (correo REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CONSTRAINT CHK_curp CHECK (curp REGEXP '^[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[0-9]{2}$'),
    FOREIGN KEY (id_convocatoria) REFERENCES convocatorias(id_convocatoria),
    FOREIGN KEY (correo) REFERENCES tokens_correos(correo)
) ENGINE=InnoDB;

-- Tabla costos_examen
CREATE TABLE costos_examen (
    id_convocatoria INT PRIMARY KEY,
    costo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_convocatoria) REFERENCES convocatorias(id_convocatoria),
    CONSTRAINT CHK_costo CHECK (costo > 0)
) ENGINE=InnoDB;

-- Tabla catalogo_carreras
CREATE TABLE catalogo_carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    estatus ENUM('activa', 'inactiva') NOT NULL DEFAULT 'activa',
    fecha_alta DATE NOT NULL,
    CONSTRAINT UK_nombre_carrera UNIQUE (nombre_carrera)
)ENGINE=InnoDB;

-- Tabla opciones_carrera
CREATE TABLE opciones_carrera (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aspirante_id INT,
    carrera_id INT,
    prioridad INT NOT NULL,
    FOREIGN KEY (aspirante_id) REFERENCES aspirantes(id_aspirante),
    FOREIGN KEY (carrera_id) REFERENCES catalogo_carreras(id_carrera),
    CONSTRAINT CHK_prioridad CHECK (prioridad >= 1),
    CONSTRAINT UK_aspirante_convocatoria_prioridad UNIQUE (aspirante_id, prioridad),
    CONSTRAINT UK_aspirante_convocatoria_carrera UNIQUE (aspirante_id, carrera_id)
) ENGINE=InnoDB;

-- Trigger para asegurar que la carrera esté activa antes de insertar en opciones_carrera
DELIMITER //

CREATE TRIGGER before_opciones_carrera_insert
BEFORE INSERT ON opciones_carrera
FOR EACH ROW
BEGIN
    DECLARE carrera_status VARCHAR(10);

    -- Obtiene el estatus de la carrera
    SELECT estatus INTO carrera_status
    FROM catalogo_carreras
    WHERE id_carrera = NEW.carrera_id;

    -- Verifica si la carrera está activa
    IF carrera_status != 'activa' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La carrera no está activa';
    END IF;
END //

DELIMITER ;

-- Trigger para asegurar que la carrera esté activa antes de actualizar en opciones_carrera
DELIMITER //

CREATE TRIGGER before_opciones_carrera_update
BEFORE UPDATE ON opciones_carrera
FOR EACH ROW
BEGIN
    DECLARE carrera_status VARCHAR(10);

    -- Obtiene el estatus de la carrera
    SELECT estatus INTO carrera_status
    FROM catalogo_carreras
    WHERE id_carrera = NEW.carrera_id;

    -- Verifica si la carrera está activa
    IF carrera_status != 'activa' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'La carrera no está activa';
    END IF;
END //

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

-- Tabla aspirantes
CREATE TABLE aspirantes (
    id_aspirante INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    correo VARCHAR(100) NOT NULL,
    curp VARCHAR(18) NOT NULL,
    CONSTRAINT UK_correo UNIQUE (correo),
    CONSTRAINT UK_curp UNIQUE (curp),
    CONSTRAINT CHK_correo CHECK (correo REGEXP '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'),
    CONSTRAINT CHK_curp CHECK (curp REGEXP '^[A-Z]{4}[0-9]{6}[HM][A-Z]{5}[0-9]{2}$')
);

-- Tabla convocatorias
CREATE TABLE convocatorias (
    id_convocatoria INT AUTO_INCREMENT PRIMARY KEY,
    anio INT NOT NULL,
    numero_convocatoria INT NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    CONSTRAINT UK_anio_numero UNIQUE (anio, numero_convocatoria),
    CONSTRAINT CHK_numero_convocatoria CHECK (numero_convocatoria IN (1, 2))
);

-- Tabla costos_examen
CREATE TABLE costos_examen (
    id_convocatoria INT PRIMARY KEY,
    costo DECIMAL(10, 2) NOT NULL,
    FOREIGN KEY (id_convocatoria) REFERENCES convocatorias(id_convocatoria),
    CONSTRAINT CHK_costo CHECK (costo > 0)
);

-- Tabla catalogo_carreras
CREATE TABLE catalogo_carreras (
    id_carrera INT AUTO_INCREMENT PRIMARY KEY,
    nombre_carrera VARCHAR(100) NOT NULL,
    estatus ENUM('activa', 'inactiva') NOT NULL DEFAULT 'activa',
    fecha_alta DATE NOT NULL,
    CONSTRAINT UK_nombre_carrera UNIQUE (nombre_carrera)
);

-- Tabla opciones_carrera
CREATE TABLE opciones_carrera (
    id INT AUTO_INCREMENT PRIMARY KEY,
    aspirante_id INT,
    convocatoria_id INT,
    carrera_id INT,
    prioridad INT NOT NULL,
    FOREIGN KEY (aspirante_id) REFERENCES aspirantes(id_aspirante),
    FOREIGN KEY (convocatoria_id) REFERENCES convocatorias(id_convocatoria),
    FOREIGN KEY (carrera_id) REFERENCES catalogo_carreras(id_carrera),
    CONSTRAINT CHK_prioridad CHECK (prioridad >= 1),
    CONSTRAINT UK_aspirante_convocatoria_prioridad UNIQUE (aspirante_id, convocatoria_id, prioridad),
    CONSTRAINT UK_aspirante_convocatoria_carrera UNIQUE (aspirante_id, convocatoria_id, carrera_id),
    CONSTRAINT UK_aspirante_convocatoria UNIQUE (aspirante_id, convocatoria_id) 
);

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

DELIMITER ;

-- Tabla registros
CREATE TABLE registros (
    id_registro INT AUTO_INCREMENT PRIMARY KEY,
    aspirante_id INT,
    estado ENUM('PENDIENTE', 'COMPLETO') NOT NULL DEFAULT 'PENDIENTE',
    FOREIGN KEY (aspirante_id) REFERENCES aspirantes(id_aspirante)
);

-- Tabla tokens
CREATE TABLE tokens (
    id_token INT AUTO_INCREMENT PRIMARY KEY,
    registro_id INT,
    token VARCHAR(255) NOT NULL,
    fecha_generacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (registro_id) REFERENCES registros(id_registro)
);

-- Trigger para validar la generación de tokens
DELIMITER //

CREATE TRIGGER before_token_insert
BEFORE INSERT ON tokens
FOR EACH ROW
BEGIN
    DECLARE registro_estado ENUM('PENDIENTE', 'COMPLETO');

    -- Obtiene el estado del registro
    SELECT estado INTO registro_estado
    FROM registros
    WHERE id_registro = NEW.registro_id;

    -- Verifica si el estado del registro es 'COMPLETO'
    IF registro_estado = 'COMPLETO' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No se pueden generar tokens para un registro completo';
    END IF;
END //

DELIMITER ;

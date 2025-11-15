-- ========= Creación de la Tabla DEPTO =========
-- Almacena la información de los departamentos de la empresa.
CREATE TABLE DEPTO (
    ID_DEPTO INT PRIMARY KEY,
    NOMBRE_DEPTO VARCHAR(100) NOT NULL,
    UBICACION VARCHAR(255),
    FECHA_CREACION DATE,
    PRESUPUESTO DECIMAL(12, 2)
);

-- ========= Creación de la Tabla EMPLEADOS =========
-- Almacena los registros de los empleados y su departamento asociado.
CREATE TABLE EMPLEADOS (
    ID_EMPLEADO INT PRIMARY KEY,
    NOMBRE VARCHAR(50) NOT NULL,
    APELLIDO VARCHAR(50) NOT NULL,
    CARGO VARCHAR(100),
    ID_DEPTO INT,
    SUELDO DECIMAL(10, 2),
    FECHA_INGRESO DATE,
    EMAIL VARCHAR(100) UNIQUE,
    TELEFONO VARCHAR(20),
    CONSTRAINT fk_depto
        FOREIGN KEY (ID_DEPTO) 
        REFERENCES DEPTO(ID_DEPTO)
);

USE DrHouseMD;
GO

-- DDL: 1. Tabla Pacientes (Datos atómicos y únicos)
CREATE TABLE PacientesNormalizados (
    PacienteID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Direccion NVARCHAR(200),
    Telefono NVARCHAR(15),
    DoctorAsignado NVARCHAR(100)
);

---------------------------------------------------

-- DDL: 2. Tabla Recetas (Detalle de cada medicamento, resolviendo la 1FN)
CREATE TABLE Recetas (
    RecetaID INT PRIMARY KEY IDENTITY(1, 1), -- Clave primaria auto-incremental para esta nueva entidad
    PacienteID INT NOT NULL,               -- Clave foránea que referencia al paciente
    Medicamento NVARCHAR(100) NOT NULL,    -- Valor atómico: un solo medicamento
    Dosis NVARCHAR(50),                    -- Valor atómico: la dosis de ese medicamento
    
    -- Restricción de Integridad Referencial
    FOREIGN KEY (PacienteID) REFERENCES PacientesNormalizados(PacienteID)
);
GO

-- DML: Insertar datos en la tabla PacientesNormalizados (Datos de la 1FN)
INSERT INTO PacientesNormalizados (PacienteID, Nombre, Direccion, Telefono, DoctorAsignado)
VALUES
    (1, 'John Doe', '123 Main St', '555-1234', 'Dr. Gregory House'),
    (2, 'Jane Smith', '456 Oak St', '555-5678', 'Dr. Lisa Cuddy'),
    (3, 'Alice Johnson', '789 Pine St', '555-8765', 'Dr. James Wilson');

---------------------------------------------------

-- DML: Insertar datos en la tabla Recetas (Resolución de la atomicidad)

-- Recetas para John Doe (ID 1): Ibuprofeno 200mg, Paracetamol 500mg
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(1, 'Ibuprofeno', '200mg');
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(1, 'Paracetamol', '500mg');

-- Recetas para Jane Smith (ID 2): Amoxicilina 500mg, Loratadina 10mg
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(2, 'Amoxicilina', '500mg');
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(2, 'Loratadina', '10mg');

-- Recetas para Alice Johnson (ID 3): Metformina 850mg, Atorvastatina 20mg
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(3, 'Metformina', '850mg');
INSERT INTO Recetas (PacienteID, Medicamento, Dosis) VALUES
(3, 'Atorvastatina', '20mg');
GO

-- DQL: Contar cuántos pacientes toman Ibuprofeno
SELECT
    COUNT(R.PacienteID) AS TotalPacientesConIbuprofeno
FROM
    Recetas R
WHERE
    R.Medicamento = 'Ibuprofeno';
GO

-- Paso 1: Crear la tabla que viola la 2FN (Clave Primaria Compuesta)
CREATE TABLE DiagnosticosDetalleMal (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Enfermedad NVARCHAR(100) NOT NULL,  -- Depende solo de DiagnosticoID (parcial)
    Dosis NVARCHAR(50),
    MedicoAsignado NVARCHAR(50),        -- Depende solo de DiagnosticoID (parcial)
    
    PRIMARY KEY (DiagnosticoID, Medicamento) -- Clave Compuesta
);
GO

-- Paso 2: Insertar datos con dependencias parciales
INSERT INTO DiagnosticosDetalleMal (DiagnosticoID, Medicamento, Enfermedad, Dosis, MedicoAsignado)
VALUES
    -- Diagnostico 1002 (Neurocisticercosis por Dr. House)
    (1002, 'Albendazol', 'Neurocisticercosis', '400mg', 'Dr. Gregory House'),
    (1002, 'Dexametasona', 'Neurocisticercosis', '2mg', 'Dr. Gregory House'),
    
    -- Diagnostico 1014 (Sarcoma de Ewing por Dr. Taub)
    (1014, 'Doxorrubicina', 'Sarcoma de Ewing', '75mg', 'Dr. Chris Taub'),
    (1014, 'Vincristina', 'Sarcoma de Ewing', '1.5mg', 'Dr. Chris Taub');
GO

-- Paso 3: Crear las tablas normalizadas (2FN)

-- DDL: 1. Tabla de Cabecera (Depende SOLAMENTE de DiagnosticoID)
CREATE TABLE DiagnosticosCabecera_2FN (
    DiagnosticoID INT PRIMARY KEY,
    Enfermedad NVARCHAR(100) NOT NULL, -- Eliminada la dependencia parcial
    MedicoAsignado NVARCHAR(50) NOT NULL
);

-- DDL: 2. Tabla de Detalle (Depende de la Clave Compuesta: DiagnosticoID + Medicamento)
CREATE TABLE RecetasDetalle_2FN (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50),
    
    PRIMARY KEY (DiagnosticoID, Medicamento),
    FOREIGN KEY (DiagnosticoID) REFERENCES DiagnosticosCabecera_2FN(DiagnosticoID) -- FK a la cabecera
);
GO

-- Paso 4: Insertar datos en la tabla Cabecera (sin repetición)
INSERT INTO DiagnosticosCabecera_2FN (DiagnosticoID, Enfermedad, MedicoAsignado)
VALUES
    (1002, 'Neurocisticercosis', 'Dr. Gregory House'),
    (1014, 'Sarcoma de Ewing', 'Dr. Chris Taub');

-- Paso 5: Insertar datos en la tabla Detalle (solo medicamentos)
INSERT INTO RecetasDetalle_2FN (DiagnosticoID, Medicamento, Dosis)
VALUES
    (1002, 'Albendazol', '400mg'),
    (1002, 'Dexametasona', '2mg'),
    (1014, 'Doxorrubicina', '75mg'),
    (1014, 'Vincristina', '1.5mg');
GO

SELECT * FROM DiagnosticosDetalleMal;
SELECT * FROM DiagnosticosCabecera_2FN;
SELECT * FROM RecetasDetalle_2FN;


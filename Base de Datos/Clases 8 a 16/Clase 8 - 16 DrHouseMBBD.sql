/*
================================================================================
 SCRIPT UNIFICADO DE BASE DE DATOS: DrHouseMBD
================================================================================
 Contenido:
 1. Creación de la Base de Datos
 2. DDL - Tablas Base (Medicos, Pacientes, Diagnosticos)
 3. DML - Inserción de Datos Base (Doctores y Pacientes de todas las demos)
 4. DDL - Objetos Avanzados (Triggers, Vistas, Funciones, Procedimientos)
 5. TCL - Demostración de Transacciones (ACID)
 6. DDL/DML - Demostración de Normalización (1FN, 2FN, 3FN, 4FN, 5FN)
 7. DQL - Consultas de Verificación
================================================================================
*/

-- Bloque 1: Creación de la Base de Datos
CREATE DATABASE DrHouseMBBD;
GO

USE DrHouseMBBD;
GO

/*
--------------------------------------------------------------------------------
 Bloque 2: DDL - Tablas Base
--------------------------------------------------------------------------------
*/

PRINT '--- Creando Tablas Base (Medicos, Pacientes, Diagnosticos) ---';

CREATE TABLE Medicos (
    MedicoID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Especialidad VARCHAR(50) NOT NULL,
    EsJefe INT DEFAULT 0
);

CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Episodio VARCHAR(100) NOT NULL,
    FechaIngreso DATE NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Activo', 'Resuelto', 'Fallecido'))
);

-- Esquema corregido: incluye todas las columnas necesarias desde el inicio
CREATE TABLE Diagnosticos (
    DiagnosticoID INT PRIMARY KEY IDENTITY(1001, 1),
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    FechaDiagnostico DATE NOT NULL,
    DiagnosticoFinal INT NOT NULL,
    Enfermedad VARCHAR(100) NOT NULL,
    CostoTratamiento DECIMAL(10, 2),
    
    FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID)
);
GO

/*
--------------------------------------------------------------------------------
 Bloque 3: DML - Inserción de Datos Base
--------------------------------------------------------------------------------
*/

PRINT '--- Insertando Datos Base (Médicos y Pacientes) ---';

-- DML: Medicos (Datos combinados)
INSERT INTO Medicos (MedicoID, Nombre, Especialidad, EsJefe) VALUES
(1, 'Gregory House', 'Nefrología/Infecciosas', 1),
(2, 'Lisa Cuddy', 'Endocrinología', 1),
(3, 'James Wilson', 'Oncología', 0),
(4, 'Eric Foreman', 'Neurología', 0),
(5, 'Allison Cameron', 'Inmunología', 0),
(6, 'Robert Chase', 'Cuidados Intensivos', 0),
(7, 'Chris Taub', 'Cirugía Plástica', 0),
(8, 'Thirteen (Remy Hadley)', 'Medicina Interna', 0),
(9, 'Lawrence Kutner', 'Medicina del Deporte', 0);
GO

-- DML: Pacientes (Datos combinados)
INSERT INTO Pacientes (PacienteID, Nombre, Episodio, FechaIngreso, Estado) VALUES
(101, 'Rebecca Adler', 'Piloto', '2004-11-16', 'Resuelto'),
(102, 'John Henry Giles', 'El Caso de la Esclava', '2005-01-25', 'Resuelto'),
(103, 'Steve McQueen', 'Un Mundo Feliz', '2006-03-28', 'Fallecido'),
(104, 'Eve', 'Misterios de la Vida', '2007-05-08', 'Activo'),
(106, 'Steve', 'La Causa Final', '2008-05-19', 'Fallecido'),
(107, 'Jeff', 'Un Gran Chico', '2009-02-09', 'Resuelto'),
(108, 'Abby', 'Espejismo', '2010-01-25', 'Activo'),
(109, 'Mike Stone', 'Inocencia Perdida', '2023-08-01', 'Resuelto'),
(110, 'Laura Brandt', 'El Cerebro de la Bestia', '2023-09-15', 'Activo'),
(111, 'Gary Evans', 'Ve a Saber', '2023-10-20', 'Resuelto'),
(112, 'Helen Cox', 'Amo mi Vida', '2023-11-05', 'Activo'),
(113, 'Daniel Flynn', 'El Corazón del Demonio', '2023-12-10', 'Resuelto'),
(114, 'Sara Lee', 'Toda la Verdad', '2024-01-05', 'Fallecido');
GO

-- DML: Diagnosticos (Datos combinados)
-- Se usa SET IDENTITY_INSERT para preservar los IDs de las demos
SET IDENTITY_INSERT Diagnosticos ON;
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, CostoTratamiento) VALUES
(1001, 101, 4, '2004-11-17', 0, 'Esclerosis Múltiple (Intento)', 5000.00),
(1002, 101, 1, '2004-11-18', 1, 'Neurocisticercosis', 45000.00),
(1003, 102, 5, '2005-01-26', 0, 'Poliarteritis Nodosa (Intento)', 8000.00),
(1004, 102, 1, '2005-01-28', 1, 'Tripanosomiasis Africana', 30000.00),
(1005, 103, 6, '2006-03-29', 0, 'Hipertensión Pulmonar (Intento)', 12000.00),
(1006, 103, 1, '2006-03-30', 1, 'Ántrax por Inhalación', 60000.00),
(1007, 104, 1, '2007-05-09', 0, 'Encefalitis por Anticuerpos (Intento)', 9000.00),
(1010, 104, 7, '2009-01-01', 0, 'Hipocondría inducida', 5000.00),
(1011, 106, 9, '2008-05-20', 0, 'Rabia (Intento)', 8000.00),
(1012, 106, 1, '2008-05-21', 1, 'Tuberculosis Multidrogorresistente', 75000.00),
(1013, 107, 8, '2009-02-10', 0, 'Síndrome de Cushing (Intento)', 6000.00),
(1014, 107, 7, '2009-02-12', 1, 'Sarcoma de Ewing', 55000.00),
(1015, 108, 1, '2010-01-26', 0, 'Fiebre Q', 1000.00),
-- IDs para la demo 5FN
(1023, 109, 5, GETDATE(), 1, 'Vasculitis de Churg-Strauss', 30000.00),
(1024, 110, 6, GETDATE(), 1, 'Mononucleosis', 500.00),
(1025, 111, 8, GETDATE(), 1, 'Síndrome de Marfan', 15000.00),
(1026, 112, 4, GETDATE(), 1, 'Leucemia Mieloide', 120000.00),
(1027, 113, 3, GETDATE(), 1, 'Carcinoma Adrenal', 95000.00),
(1028, 114, 7, GETDATE(), 1, 'Encefalitis Viral', 25000.00);
SET IDENTITY_INSERT Diagnosticos OFF;
GO

/*
--------------------------------------------------------------------------------
 Bloque 4: DDL - Objetos Avanzados (Triggers, Vistas, Funciones, SPs)
--------------------------------------------------------------------------------
*/

PRINT '--- Creando Objetos Avanzados ---';

-- DDL: Tabla de Auditoría
CREATE TABLE Diagnosticos_Auditoria (
    DiagnosticoID INT,
    PacienteID INT,
    MedicoID INT,
    FechaDiagnostico DATE,
    DiagnosticoFinal INT,
    Enfermedad VARCHAR(100),
    FechaCambio DATETIME2 DEFAULT GETDATE(),
    Accion VARCHAR(10)
);
GO

-- DDL: Triggers de Auditoría
CREATE TRIGGER trg_Diagnosticos_Insert ON Diagnosticos AFTER INSERT
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion)
    SELECT i.DiagnosticoID, i.PacienteID, i.MedicoID, i.FechaDiagnostico, i.DiagnosticoFinal, i.Enfermedad, 'INSERT' FROM inserted i;
END;
GO
CREATE TRIGGER trg_Diagnosticos_Update ON Diagnosticos AFTER UPDATE
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion)
    SELECT d.DiagnosticoID, d.PacienteID, d.MedicoID, d.FechaDiagnostico, d.DiagnosticoFinal, d.Enfermedad, 'UPDATE' FROM deleted d;
END;
GO
CREATE TRIGGER trg_Diagnosticos_Delete ON Diagnosticos AFTER DELETE
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion)
    SELECT d.DiagnosticoID, d.PacienteID, d.MedicoID, d.FechaDiagnostico, d.DiagnosticoFinal, d.Enfermedad, 'DELETE' FROM deleted d;
END;
GO

-- DDL: Vista de Rendimiento
CREATE VIEW RendimientoMedico AS
SELECT
    M.MedicoID,
    M.Nombre AS Medico,
    M.Especialidad,
    SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DiagnosticosFinales,
    SUM(CASE WHEN D.DiagnosticoFinal = 0 THEN 1 ELSE 0 END) AS IntentosFallidos,
    CAST(SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DECIMAL(10,2)) / NULLIF(COUNT(D.DiagnosticoID), 0) AS TasaExito
FROM
    Medicos M
LEFT JOIN
    Diagnosticos D ON M.MedicoID = D.MedicoID
GROUP BY
    M.MedicoID, M.Nombre, M.Especialidad;
GO

-- DDL: Función de Utilidad Neta (Corregida)
CREATE FUNCTION CalcularUtilidadNeta(@PacienteID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @IngresosTotales DECIMAL(10, 2);
    DECLARE @CostoTotal DECIMAL(10, 2);
    
    -- Corregido para manejar múltiples estados (solo 'Resuelto' genera ingresos)
    SELECT @IngresosTotales = CASE WHEN P.Estado = 'Resuelto' THEN 100000.00 ELSE 0.00 END
    FROM Pacientes P
    WHERE P.PacienteID = @PacienteID;
    
    -- Corregido para usar la columna CostoTratamiento
    SELECT @CostoTotal = ISNULL(SUM(D.CostoTratamiento), 0.00)
    FROM Diagnosticos D
    WHERE D.PacienteID = @PacienteID;

    RETURN @IngresosTotales - @CostoTotal;
END;
GO

-- DDL: Procedimiento Almacenado (Corregido)
CREATE PROCEDURE DiagnosticarPaciente
    @p_PacienteID INT,
    @p_MedicoID INT,
    @p_Enfermedad VARCHAR(100),
    @p_EsFinal BIT,
    @p_Costo DECIMAL(10, 2) = NULL
AS
BEGIN
    -- Corregido: Se usa IDENTITY, no se inserta DiagnosticoID
    -- Corregido: Se inserta CostoTratamiento
    INSERT INTO Diagnosticos (
        PacienteID,
        MedicoID,
        FechaDiagnostico,
        DiagnosticoFinal,
        Enfermedad,
        CostoTratamiento
    )
    VALUES (
        @p_PacienteID,
        @p_MedicoID,
        GETDATE(),
        @p_EsFinal,
        @p_Enfermedad,
        @p_Costo
    );

    IF @p_EsFinal = 1
    BEGIN
        UPDATE Pacientes
        SET Estado = 'Resuelto'
        WHERE PacienteID = @p_PacienteID;
    END

    SELECT 'Diagnóstico registrado.' AS Resultado;
END;
GO

/*
--------------------------------------------------------------------------------
Bloque 5: TCL - Demostración de Transacciones (ACID)
--------------------------------------------------------------------------------
*/

PRINT '--- Ejecutando Demostración ACID (COMMIT y ROLLBACK) ---';

-- Demo 1: COMMIT (Éxito)
-- Usa el Paciente 108 (Abby) y Diagnóstico 1015 (Fiebre Q)
PRINT 'Demo COMMIT:';
BEGIN TRANSACTION;
UPDATE Diagnosticos SET DiagnosticoFinal = 1, CostoTratamiento = 25000.00 WHERE DiagnosticoID = 1015;
UPDATE Pacientes SET Estado = 'Resuelto' WHERE PacienteID = 108;
COMMIT TRANSACTION;
-- Verificar COMMIT
SELECT 'Post-COMMIT' AS Estado, Estado FROM Pacientes WHERE PacienteID = 108;
GO

-- Demo 2: ROLLBACK (Falla)
-- Reiniciar datos
UPDATE Pacientes SET Estado = 'Activo' WHERE PacienteID = 108;
UPDATE Diagnosticos SET DiagnosticoFinal = 0 WHERE DiagnosticoID = 1015;
GO

PRINT 'Demo ROLLBACK (Falla de Consistencia):';
BEGIN TRANSACTION;
UPDATE Diagnosticos SET DiagnosticoFinal = 1 WHERE DiagnosticoID = 1015;

-- Forzar error de restricción CHECK
BEGIN TRY
    UPDATE Pacientes SET Estado = 'ESTADO_INVALIDO' WHERE PacienteID = 108;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error detectado. Transacción revertida (Atomicidad).';
END CATCH;
GO

-- Verificar ROLLBACK
SELECT 'Post-ROLLBACK' AS Estado, Estado FROM Pacientes WHERE PacienteID = 108; -- Sigue 'Activo'
SELECT 'Post-ROLLBACK' AS Diagnostico, DiagnosticoFinal FROM Diagnosticos WHERE DiagnosticoID = 1015; -- Sigue 0
GO

/*
--------------------------------------------------------------------------------
 Bloque 6: DDL/DML - Demostración de Normalización (1FN-5FN)
--------------------------------------------------------------------------------
*/

PRINT '--- Creando Tablas de Demostración de Normalización ---';

-- Demo 1FN (Datos Atómicos)
CREATE TABLE Demo_PacientesNormalizados (
    PacienteID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    DoctorAsignado NVARCHAR(100)
);
CREATE TABLE Demo_Recetas (
    RecetaID INT PRIMARY KEY IDENTITY(1, 1),
    PacienteID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50),
    FOREIGN KEY (PacienteID) REFERENCES Demo_PacientesNormalizados(PacienteID)
);
INSERT INTO Demo_PacientesNormalizados VALUES (1, 'John Doe', 'Dr. House'), (2, 'Jane Smith', 'Dr. Cuddy');
INSERT INTO Demo_Recetas (PacienteID, Medicamento, Dosis) VALUES (1, 'Ibuprofeno', '200mg'), (1, 'Paracetamol', '500mg');
GO

-- Demo 2FN (Dependencia Parcial)
CREATE TABLE Demo_DiagnosticosDetalleMal (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Enfermedad NVARCHAR(100) NOT NULL,
    MedicoAsignado NVARCHAR(50),
    PRIMARY KEY (DiagnosticoID, Medicamento)
);
INSERT INTO Demo_DiagnosticosDetalleMal VALUES (1002, 'Albendazol', 'Neurocisticercosis', 'Dr. House'), (1002, 'Dexametasona', 'Neurocisticercosis', 'Dr. House');

CREATE TABLE Demo_DiagnosticosCabecera_2FN (
    DiagnosticoID INT PRIMARY KEY,
    Enfermedad NVARCHAR(100) NOT NULL,
    MedicoAsignado NVARCHAR(50) NOT NULL
);
CREATE TABLE Demo_RecetasDetalle_2FN (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50),
    PRIMARY KEY (DiagnosticoID, Medicamento),
    FOREIGN KEY (DiagnosticoID) REFERENCES Demo_DiagnosticosCabecera_2FN(DiagnosticoID)
);
INSERT INTO Demo_DiagnosticosCabecera_2FN VALUES (1002, 'Neurocisticercosis', 'Dr. House'), (1014, 'Sarcoma de Ewing', 'Dr. Taub');
INSERT INTO Demo_RecetasDetalle_2FN (DiagnosticoID, Medicamento, Dosis) VALUES (1002, 'Albendazol', '400mg'), (1002, 'Dexametasona', '2mg'), (1014, 'Doxorrubicina', '75mg');
GO

-- Demo 3FN (Dependencia Transitiva)
CREATE TABLE Demo_Lenguajes (
    IdiomaID INT PRIMARY KEY,
    IdiomaNombre NVARCHAR(50) NOT NULL
);
CREATE TABLE Demo_Medicos_Lenguajes (
    MedicoID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    IdiomaID INT NOT NULL,
    FOREIGN KEY (IdiomaID) REFERENCES Demo_Lenguajes(IdiomaID)
);
INSERT INTO Demo_Lenguajes VALUES (1, 'Inglés'), (2, 'Francés'), (3, 'Español'), (4, 'Alemán');
INSERT INTO Demo_Medicos_Lenguajes VALUES (1, 'Dr. House', 1), (3, 'Dr. Wilson', 1), (7, 'Dr. Taub', 3);
GO

-- Demo 4FN (Dependencia Multivaluada)
CREATE TABLE Demo_Medicos_4FN (
    MedicoID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
);
CREATE TABLE Demo_MedicoEspecialidad (
    MedicoID INT NOT NULL,
    Especialidad NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MedicoID, Especialidad),
    FOREIGN KEY (MedicoID) REFERENCES Demo_Medicos_4FN(MedicoID)
);
CREATE TABLE Demo_MedicoCertificacion (
    MedicoID INT NOT NULL,
    Certificacion NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MedicoID, Certificacion),
    FOREIGN KEY (MedicoID) REFERENCES Demo_Medicos_4FN(MedicoID)
);
INSERT INTO Demo_Medicos_4FN VALUES (3, 'Dr. Wilson'), (6, 'Dr. Chase');
INSERT INTO Demo_MedicoEspecialidad VALUES (3, 'Oncología'), (3, 'Cuidados Paliativos'), (6, 'Cuidados Intensivos');
INSERT INTO Demo_MedicoCertificacion VALUES (3, 'Radioterapia'), (3, 'Manejo del Dolor'), (6, 'Trasplantes');
GO

-- Demo 5FN (Dependencia de Unión)
CREATE TABLE Demo_MedicoDiagnostico_5FN (MedicoID INT NOT NULL, DiagnosticoID INT NOT NULL, PRIMARY KEY (MedicoID, DiagnosticoID));
CREATE TABLE Demo_DiagnosticoMedicamento_5FN (DiagnosticoID INT NOT NULL, Medicamento NVARCHAR(100) NOT NULL, PRIMARY KEY (DiagnosticoID, Medicamento));
CREATE TABLE Demo_MedicoMedicamento_5FN (MedicoID INT NOT NULL, Medicamento NVARCHAR(100) NOT NULL, PRIMARY KEY (MedicoID, Medicamento));
GO
-- Datos de la demo 5FN (IDs 1023-1028)
INSERT INTO Demo_MedicoDiagnostico_5FN VALUES (5, 1023), (6, 1024), (8, 1025), (4, 1026), (3, 1027), (7, 1028);
INSERT INTO Demo_DiagnosticoMedicamento_5FN VALUES (1023, 'Ciclofosfamida'), (1024, 'Antiácido'), (1025, 'Propranolol'), (1026, 'Citarabina'), (1027, 'Mitotano'), (1028, 'Ganciclovir');
INSERT INTO Demo_MedicoMedicamento_5FN VALUES (5, 'Ciclofosfamida'), (6, 'Antiácido'), (8, 'Propranolol'), (4, 'Citarabina'), (3, 'Mitotano'), (7, 'Ganciclovir');
GO

/*
--------------------------------------------------------------------------------
Bloque 7: DQL - Consultas de Verificación
--------------------------------------------------------------------------------
*/

PRINT '--- Ejecutando Consultas de Verificación ---';

-- Verificar Vista
PRINT 'Resultados de la Vista RendimientoMedico:';
SELECT * FROM RendimientoMedico ORDER BY TasaExito DESC;
GO

-- Verificar Función (Calcula Utilidad Neta para Paciente 107 (Jeff))
PRINT 'Resultado de la Función CalcularUtilidadNeta (Paciente 107):';
SELECT dbo.CalcularUtilidadNeta(107) AS UtilidadNeta_Jeff;
GO

-- Verificar Procedimiento (Ejecuta el SP para diagnosticar a Eve (104))
PRINT 'Resultado del Procedimiento Almacenado (Paciente 104):';
EXEC DiagnosticarPaciente
    @p_PacienteID = 104,
    @p_MedicoID = 1,
    @p_Enfermedad = 'Sarcoidosis (Demo SP)',
    @p_EsFinal = 1,
    @p_Costo = 45000.00;
GO
SELECT * FROM Diagnosticos WHERE PacienteID = 104 AND Enfermedad = 'Sarcoidosis (Demo SP)';
GO

-- Verificar Demo 5FN (Uniendo tablas base y tablas de demo)
PRINT 'Resultados de la Verificación de 5FN:';
SELECT
    M.Nombre AS Medico,
    D.Enfermedad AS Diagnostico,
    MM.Medicamento AS MedicamentoRecetado
FROM
    Demo_MedicoDiagnostico_5FN MD_Diag
INNER JOIN
    Demo_DiagnosticoMedicamento_5FN Diag_Med ON MD_Diag.DiagnosticoID = Diag_Med.DiagnosticoID
INNER JOIN
    Demo_MedicoMedicamento_5FN MM ON MD_Diag.MedicoID = MM.MedicoID 
    AND Diag_Med.Medicamento = MM.Medicamento
INNER JOIN
    Medicos M ON MD_Diag.MedicoID = M.MedicoID
INNER JOIN
    Diagnosticos D ON MD_Diag.DiagnosticoID = D.DiagnosticoID
WHERE
    MD_Diag.DiagnosticoID BETWEEN 1023 AND 1028
ORDER BY
    M.Nombre, D.Enfermedad;
GO

-- DDL: Creación de la Función (TVF)
CREATE FUNCTION ObtenerCasosPorEspecialidad (
    @Especialidad VARCHAR(50)
)
RETURNS TABLE
AS
RETURN (
    SELECT 
        D.DiagnosticoID,
        P.Nombre AS Paciente,
        D.Enfermedad,
        M.Nombre AS Medico,
        D.FechaDiagnostico,
        D.CostoTratamiento
    FROM 
        Diagnosticos D
    JOIN 
        Medicos M ON D.MedicoID = M.MedicoID
    JOIN 
        Pacientes P ON D.PacienteID = P.PacienteID
    WHERE 
        M.Especialidad = @Especialidad
);
GO

-- Demo: Obtener todos los casos manejados por 'Oncología'
SELECT * FROM dbo.ObtenerCasosPorEspecialidad('Oncología');

-- Demo: Obtener todos los casos manejados por 'Neurología'
SELECT * FROM dbo.ObtenerCasosPorEspecialidad('Neurología');
GO

-- Asignar supervisores (Cuddy es la cima, House reporta a Cuddy, el equipo reporta a House)
UPDATE Medicos SET EsJefe = 2 WHERE MedicoID = 1;  -- House reporta a Cuddy
UPDATE Medicos SET EsJefe = 1 WHERE MedicoID IN (4, 5, 6, 7, 8, 9); -- Equipo reporta a House
GO

-- Definir la CTE recursiva
WITH CadenaDeMando AS (
-- 1. Miembro Ancla (El punto de inicio: Dr. Taub)
    SELECT 
        MedicoID,
        Nombre,
        EsJefe,
        0 AS NivelJerarquico -- Nivel 0 (inicio)
    FROM 
            Medicos
        WHERE 
        MedicoID = 7 -- ID de Chris Taub

UNION ALL

-- 2. Miembro Recursivo (La consulta que se une a sí misma)
    SELECT 
        M.MedicoID,
        M.Nombre,
        M.EsJefe,
    C.NivelJerarquico + 1 -- Incrementar el nivel
        FROM 
        Medicos M
    INNER JOIN 
    CadenaDeMando C ON M.MedicoID = C.EsJefe -- El supervisor del nivel anterior
)
-- 3. Consulta final
SELECT 
    NivelJerarquico,
    Nombre,
    MedicoID
FROM 
    CadenaDeMando
ORDER BY 
    NivelJerarquico;
GO

USE DrHouseMBD;
GO
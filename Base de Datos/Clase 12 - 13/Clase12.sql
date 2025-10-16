CREATE DATABASE DrHouseMD;
USE DrHouseMD;

-- 1. Tabla Medicos
CREATE TABLE Medicos (
    MedicoID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Especialidad VARCHAR(50) NOT NULL,
    EsJefe INT DEFAULT 0 -- 1=TRUE, 0=FALSE
);

-- 2. Tabla Pacientes
CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Episodio VARCHAR(100) NOT NULL,
    FechaIngreso DATE NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Activo', 'Resuelto', 'Fallecido'))
);

-- 3. Tabla Diagnosticos
CREATE TABLE Diagnosticos (
    DiagnosticoID INT PRIMARY KEY,
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    FechaDiagnostico DATE NOT NULL,
    DiagnosticoFinal INT NOT NULL, -- 1=TRUE (Final), 0=FALSE (Intento/Erróneo)
    Enfermedad VARCHAR(100) NOT NULL,
    FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID)
);

-- Datos para Medicos
INSERT INTO Medicos (MedicoID, Nombre, Especialidad, EsJefe) VALUES
(1, 'Gregory House', 'Nefrología/Enfermedades Infecciosas', 1), -- TRUE
(2, 'Lisa Cuddy', 'Endocrinología', 1), -- TRUE
(3, 'James Wilson', 'Oncología', 0), -- FALSE
(4, 'Eric Foreman', 'Neurología', 0), -- FALSE
(5, 'Allison Cameron', 'Inmunología', 0), -- FALSE
(6, 'Robert Chase', 'Cuidados Intensivos', 0); -- FALSE

-- Datos para Pacientes
INSERT INTO Pacientes (PacienteID, Nombre, Episodio, FechaIngreso, Estado) VALUES
(101, 'Rebecca Adler', 'Piloto', '2004-11-16', 'Resuelto'),
(102, 'John Henry Giles', 'El Caso de la Esclava', '2005-01-25', 'Resuelto'),
(103, 'Steve McQueen', 'Un Mundo Feliz', '2006-03-28', 'Fallecido'),
(104, 'Eve', 'Misterios de la Vida', '2007-05-08', 'Activo');

-- Datos para Diagnosticos
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad) VALUES
(1001, 101, 4, '2004-11-17', 0, 'Esclerosis Múltiple (Intento)'), -- 0=FALSE
(1002, 101, 1, '2004-11-18', 1, 'Neurocisticercosis'), -- 1=TRUE
(1003, 102, 5, '2005-01-26', 0, 'Poliarteritis Nodosa (Intento)'),
(1004, 102, 1, '2005-01-28', 1, 'Tripanosomiasis Africana'),
(1005, 103, 6, '2006-03-29', 0, 'Hipertensión Pulmonar (Intento)'),
(1006, 103, 1, '2006-03-30', 1, 'Ántrax por Inhalación'),
(1007, 104, 1, '2007-05-09', 0, 'Encefalitis por Anticuerpos (Intento)'); -- 0=FALSE
-- Nota: El diagnóstico final para Eve aún no se ha determinado.

-- Consulta para obtener los nombres de los pacientes que tuvieron diagnósticos fallidos (DiagnosticoFinal = 0)
SELECT
    Nombre
FROM
    Pacientes
WHERE
    PacienteID IN (
        SELECT DISTINCT
            PacienteID
        FROM
            Diagnosticos
        WHERE
            DiagnosticoFinal = 0 -- Filtrado por 0 (FALSE)
    );

-- DEMOSTRACIONES DE VENTANA (OVER)

SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    D.Enfermedad,
    D.FechaDiagnostico,
    -- Aplica la función de ventana
    ROW_NUMBER() OVER (
        PARTITION BY D.PacienteID -- Reinicia el conteo para cada paciente
        ORDER BY D.FechaDiagnostico DESC -- Ordena por fecha descendente (más reciente primero)
    ) AS OrdenDiagnostico,
    CASE
        WHEN ROW_NUMBER() OVER (
            PARTITION BY D.PacienteID
            ORDER BY D.FechaDiagnostico DESC
        ) = 1 THEN 'Último Diagnóstico' -- TRUE
        ELSE 'Anterior' -- FALSE
    END AS EsMasReciente
FROM
    Diagnosticos D
JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
ORDER BY
    Paciente, FechaDiagnostico DESC;

--1A. PREPARACION: TABLA DE AUDITORIA
-- Creamos una tabla para almacenar el registro historico de cambios en los diagnósticos
-- DDL DE AUDITORÍA
-- 1. Eliminar la tabla antigua si existe
IF OBJECT_ID('Diagnosticos_Auditoria', 'U') IS NOT NULL
    DROP TABLE Diagnosticos_Auditoria;

-- 2. Creación corregida de la tabla de Auditoría
CREATE TABLE Diagnosticos_Auditoria (
    DiagnosticoID INT,
    PacienteID INT,
    MedicoID INT,
    FechaDiagnostico DATE,
    DiagnosticoFinal INT,
    Enfermedad VARCHAR(100),
    FechaCambio DATETIME2 DEFAULT GETDATE(), -- Tipo y DEFAULT corregidos para SQL Server
    Accion VARCHAR(10)
);

-- TRIGGERS (Reejecución necesaria después de recrear la tabla)

-- Trigger para registrar INSERTS
CREATE TRIGGER trg_Diagnosticos_Insert
ON Diagnosticos
AFTER INSERT
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (
        DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion
    )
    SELECT
        i.DiagnosticoID, i.PacienteID, i.MedicoID, i.FechaDiagnostico, i.DiagnosticoFinal, i.Enfermedad, 'INSERT'
    FROM
        inserted i;
END;
GO

-- Trigger para registrar UPDATES (captura el valor ANTES del cambio)
CREATE TRIGGER trg_Diagnosticos_Update
ON Diagnosticos
AFTER UPDATE
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (
        DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion
    )
    SELECT
        d.DiagnosticoID, d.PacienteID, d.MedicoID, d.FechaDiagnostico, d.DiagnosticoFinal, d.Enfermedad, 'UPDATE'
    FROM
        deleted d;
END;
GO

-- Trigger para registrar DELETES
CREATE TRIGGER trg_Diagnosticos_Delete
ON Diagnosticos
AFTER DELETE
AS
BEGIN
    INSERT INTO Diagnosticos_Auditoria (
        DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, Accion
    )
    SELECT
        d.DiagnosticoID, d.PacienteID, d.MedicoID, d.FechaDiagnostico, d.DiagnosticoFinal, d.Enfermedad, 'DELETE'
    FROM
        deleted d;
END;

-- 2A. PRUEBAS DE TRIGGERS
-- Insertar un nuevo diagnóstico (debería activar el trigger de INSERT)
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad) VALUES
(1008, 104, 2, '2024-06-01', 1, 'Lupus Eritematoso Sistémico'); -- Nuevo diagnóstico para Eve
-- Actualizar un diagnóstico existente (debería activar el trigger de UPDATE)
UPDATE Diagnosticos SET DiagnosticoFinal = 1 WHERE DiagnosticoID = 1001;
-- Eliminar un diagnóstico (debería activar el trigger de DELETE)
DELETE FROM Diagnosticos WHERE DiagnosticoID = 1005;
-- Consultar la tabla de auditoría para verificar los registros
SELECT * FROM Diagnosticos_Auditoria ORDER BY FechaCambio DESC;

-- DDL: Creación de la Vista
CREATE VIEW RendimientoMedico AS
SELECT
    M.MedicoID,
    M.Nombre AS Medico,
    M.Especialidad,
    -- Conteo de diagnósticos finales (1)
    SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DiagnosticosFinales,
    -- Conteo de intentos fallidos (0)
    SUM(CASE WHEN D.DiagnosticoFinal = 0 THEN 1 ELSE 0 END) AS IntentosFallidos,
    -- Cálculo de la 'Tasa de Éxito'
    CAST(SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DECIMAL) /
    COUNT(D.DiagnosticoID) AS TasaExito
FROM
    Medicos M
LEFT JOIN
    Diagnosticos D ON M.MedicoID = D.MedicoID
GROUP BY
    M.MedicoID, M.Nombre, M.Especialidad;
GO

-- DQL: Consulta la Vista para obtener las métricas de rendimiento
SELECT
    Medico,
    Especialidad,
    DiagnosticosFinales,
    IntentosFallidos,
    TasaExito
FROM
    RendimientoMedico
WHERE
    DiagnosticosFinales > 0 -- Excluye a los médicos sin ningún diagnóstico final
ORDER BY
    TasaExito DESC, DiagnosticosFinales DESC;

-- DDL: Creación de la Vista con Filtro de Especialidad
CREATE VIEW RendimientoMedicoEspecialidad AS
SELECT
    M.MedicoID,
    M.Nombre AS Medico,
    M.Especialidad,
    SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DiagnosticosFinales,
    SUM(CASE WHEN D.DiagnosticoFinal = 0 THEN 1 ELSE 0 END) AS IntentosFallidos,
    CAST(SUM(CASE WHEN D.DiagnosticoFinal = 1 THEN 1 ELSE 0 END) AS DECIMAL) / NULLIF(COUNT(D.DiagnosticoID), 0) AS TasaExito
FROM
    Medicos M
LEFT JOIN
    Diagnosticos D ON M.MedicoID = D.MedicoID
GROUP BY
    M.MedicoID,
    M.Nombre, -- Corrección: Usar M.Nombre
    M.Especialidad; -- Comas añadidas
-- GO -- Este comando es específico de SQL Server/SSMS y debe ir al final

-- DQL: Consulta la Vista para obtener las métricas de rendimiento por especialidad
SELECT
    Medico,
    Especialidad,
    DiagnosticosFinales,
    IntentosFallidos,
    TasaExito
FROM
    RendimientoMedicoEspecialidad
WHERE
    DiagnosticosFinales > 0
ORDER BY
    TasaExito DESC,
    DiagnosticosFinales DESC;
-- GO -- Este comando es específico de SQL Server/SSMS y debe ir al final

-- DDL: Visualización implícita
-- PRIMARY KEY (PacienteID) ya crea un índice Clustered en Pacientes.
-- Esto asegura que la búsqueda por PacienteID sea la más rápida.
-- FOREIGN KEY (PacienteID) en Diagnosticos crea un índice no Clustered automáticamente.
-- Si se desea un índice adicional para optimizar búsquedas por MedicoID en Diagnosticos:
CREATE INDEX IDX_MedicoID ON Diagnosticos(MedicoID);
-- GO -- Este comando es específico de SQL Server/SSMS y debe ir al final
-- DQL: Consulta para verificar el uso del índice
SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    M.Nombre AS Medico,
    D.Enfermedad,
    D.FechaDiagnostico
FROM
    Diagnosticos D
JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
JOIN
    Medicos M ON D.MedicoID = M.MedicoID
WHERE
    P.PacienteID = 10
    OR D.MedicoID = 1; -- Búsqueda por MedicoID para usar el índice
-- GO -- Este comando es específico de SQL Server/SSMS y debe ir al final
USE DrHouseMD;
GO


-- DDL: Creación del Procedimiento Almacenado
CREATE PROCEDURE DiagnosticarPaciente
    @p_PacienteID INT,              -- ID del paciente
    @p_MedicoID INT,                -- ID del médico que realiza el diagnóstico
    @p_Enfermedad VARCHAR(100),     -- Nombre de la enfermedad diagnosticada
    @p_EsFinal BIT,                 -- 1 si es final (BIT es el tipo para BOOLEAN/INT en SQL Server)
    @p_Costo DECIMAL(10, 2) = NULL  -- Costo opcional del tratamiento
AS
BEGIN
    -- Se inserta el nuevo diagnóstico en la tabla
    INSERT INTO Diagnosticos (
        PacienteID,
        MedicoID,
        FechaDiagnostico,
        DiagnosticoFinal,
        Enfermedad
    )
    VALUES (
        @p_PacienteID,
        @p_MedicoID,
        GETDATE(), -- Usa la fecha y hora actuales
        @p_EsFinal,
        @p_Enfermedad
); -- @p_Costo no se usa aquí, ya que CostoTratamiento no existe en la tabla Diagnosticos

    -- Si el diagnóstico es el final (1), actualiza el estado del paciente
    IF @p_EsFinal = 1
    BEGIN
        UPDATE Pacientes
        SET Estado = 'Resuelto'
        WHERE PacienteID = @p_PacienteID;
    END

    -- Mensaje de confirmación
    SELECT 'Diagnóstico registrado y estado del paciente actualizado (si es final).' AS Resultado;
END;
GO

-- Ejemplo de ejecución del procedimiento almacenado
-- DQL: Ejecución 1 - Diagnóstico Intento (no es final)
-- Paciente 104, Médico 5 (Cameron), Intento de Lupus, NO final (0)
EXEC DiagnosticarPaciente
    @p_PacienteID = 104,
    @p_MedicoID = 5,
    @p_Enfermedad = 'Lupus (Intento #2)',
    @p_EsFinal = 0;

-- DQL: Ejecución 2 - Diagnóstico Final
-- Paciente 104, Médico 1 (House), Diagnóstico de Sarcoidosis, ES final (1)
EXEC DiagnosticarPaciente
    @p_PacienteID = 104,
    @p_MedicoID = 1,
    @p_Enfermedad = 'Sarcoidosis',
    @p_EsFinal = 1,
    @p_Costo = 45000.00;
GO

SELECT
    P.Nombre AS Paciente,
    P.Episodio,
    P.Estado AS EstadoPaciente,
    D.Enfermedad AS DiagnosticoRegistrado,
    M.Nombre AS MedicoEquipo,
    D.FechaDiagnostico,
    CASE D.DiagnosticoFinal
        WHEN 1 THEN 'Sí (Final)'
        ELSE 'No (Intento)'
    END AS EsDiagnosticoFinal
FROM
    Diagnosticos D
INNER JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
INNER JOIN
    Medicos M ON D.MedicoID = M.MedicoID
ORDER BY
    P.Nombre, D.FechaDiagnostico;

SELECT
    P.Nombre AS Paciente,
    P.Estado,
    -- Ingresos Simulados: 100,000 solo si el paciente fue 'Resuelto'
    SUM(CASE
        WHEN P.Estado = 'Resuelto' THEN 100000.00
        ELSE 0.00
    END) AS IngresosTotales,

    -- Utilidad Neta: Ingresos - Costo Total de Tratamiento (calculado directamente)
    (
        SUM(CASE
            WHEN P.Estado = 'Resuelto' THEN 100000.00
            ELSE 0.00
        END) - 0 -- No hay columna CostoTratamiento en la tabla Diagnosticos
    ) AS UtilidadNeta
FROM
    Pacientes P
INNER JOIN
    Diagnosticos D ON P.PacienteID = D.PacienteID -- La columna CostoTratamiento no existe en la tabla Diagnosticos
GROUP BY
    P.PacienteID, P.Nombre, P.Estado
ORDER BY
    UtilidadNeta DESC;

-- Creacion de funcion para calcular utilidad neta
-- DDL: Eliminación de la función existente para recrearla con las correcciones
IF OBJECT_ID('CalcularUtilidadNeta') IS NOT NULL
    DROP FUNCTION CalcularUtilidadNeta;
GO
-- DDL: Creación de la Función de Utilidad Neta
CREATE FUNCTION CalcularUtilidadNeta(@PacienteID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @IngresosTotales DECIMAL(10, 2);
    DECLARE @CostoTotal DECIMAL(10, 2); -- Se renombra para claridad
    
    -- 1. Calcular ingresos totales (simulados)
    SELECT @IngresosTotales = SUM(CASE
        WHEN P.Estado = 'Resuelto' THEN 100000.00
        ELSE 0.00
    END)
    FROM Pacientes P
    WHERE P.PacienteID = @PacienteID;

    -- 2. Calcular costo total del tratamiento real (desde la tabla Diagnosticos)
    -- La columna CostoTratamiento no existe en la tabla Diagnosticos.
    -- Se simula un costo de 0 para este ejemplo.
    SET @CostoTotal = 0.00;

    -- 3. Calcular utilidad neta (Ingresos - Costos)
    RETURN @IngresosTotales - @CostoTotal;
END;
GO

-- DQL: Uso de la función para obtener la utilidad neta por paciente
SELECT
    P.Nombre AS Paciente,
    P.Estado,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNeta
FROM
    Pacientes P
ORDER BY
    UtilidadNeta DESC;
GO

-- DQL: 2 - Listar todos los diagnósticos con detalles del paciente y médico
-- DQL: Uso de la función en una consulta
SELECT
    P.Nombre,
    P.Estado,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNetaCalculada
FROM
    Pacientes P
WHERE
    P.PacienteID IN (101, 103, 104); -- Ejemplos de pacientes
GO
-- DQL: Listar todos los diagnósticos con detalles del paciente y médico
SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    M.Nombre AS Medico,
    D.Enfermedad,
    D.FechaDiagnostico,
    D.DiagnosticoFinal,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNetaCalculada
FROM
    Diagnosticos D
JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
JOIN
    Medicos M ON D.MedicoID = M.MedicoID
ORDER BY
    P.Nombre, D.FechaDiagnostico;
GO

ALTER TABLE Diagnosticos
ADD CostoTratamiento DECIMAL(10, 2);

-- Nuevo inserto de variables al Codigo
INSERT INTO Medicos (MedicoID, Nombre, Especialidad, EsJefe) VALUES
(7, 'Chris Taub', 'Cirugía Plástica', 0),
(8, 'Thirteen (Remy Hadley)', 'Medicina Interna', 0),
(9, 'Lawrence Kutner', 'Medicina del Deporte', 0);
GO

-- Se añade a nuevos pacientes
INSERT INTO Pacientes (PacienteID, Nombre, Episodio, FechaIngreso, Estado) VALUES
(106, 'Steve', 'La Causa Final', '2008-05-19', 'Fallecido'),
(107, 'Jeff', 'Un Gran Chico', '2009-02-09', 'Resuelto'),
(108, 'Abby', 'Espejismo', '2010-01-25', 'Activo');

-- Se añade un nuevo diagnóstico a un paciente existente (Eve, 104) para fines de demo
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, CostoTratamiento) VALUES
(1010, 104, 7, '2009-01-01', 0, 'Hipocondría inducida', 5000.00);

-- Diagnósticos para los nuevos pacientes
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, CostoTratamiento) VALUES
(1011, 106, 9, '2008-05-20', 0, 'Rabia (Intento)', 8000.00),
(1012, 106, 1, '2008-05-21', 1, 'Tuberculosis Multidrogorresistente', 75000.00), -- Paciente 106 muere aunque el diagnóstico es final
(1013, 107, 8, '2009-02-10', 0, 'Síndrome de Cushing (Intento)', 6000.00),
(1014, 107, 7, '2009-02-12', 1, 'Sarcoma de Ewing', 55000.00),
(1015, 108, 1, '2010-01-26', 0, 'Fiebre Q', 1000.00);
GO

-- Verificación de los datos insertados
SELECT
    M.Nombre AS Medico,
    COUNT(D.DiagnosticoID) AS TotalDiagnosticosParticipados
FROM
    Medicos M
LEFT JOIN
    Diagnosticos D ON M.MedicoID = D.MedicoID
WHERE
    M.MedicoID IN (7, 8, 9) -- Filtrado por los IDs del nuevo equipo
GROUP BY
    M.Nombre
ORDER BY
    TotalDiagnosticosParticipados DESC;
GO

-- Verificación de los datos insertados
SELECT
    P.Nombre AS Paciente,
    P.Episodio,
    P.Estado AS EstadoPaciente,
    D.Enfermedad AS DiagnosticoRegistrado,
    M.Nombre AS MedicoEquipo,
    D.FechaDiagnostico,
    CASE D.DiagnosticoFinal
        WHEN 1 THEN 'Sí (Final)'
        ELSE 'No (Intento)'
    END AS EsDiagnosticoFinal,
    D.CostoTratamiento
FROM
    Diagnosticos D
INNER JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
INNER JOIN
    Medicos M ON D.MedicoID = M.MedicoID
ORDER BY
    P.Nombre, D.FechaDiagnostico;
GO

-- Actualización de la función para incluir CostoTratamiento
IF OBJECT_ID('CalcularUtilidadNeta') IS NOT NULL
    DROP FUNCTION CalcularUtilidadNeta;
GO

-- DDL: Creación de la Función de Utilidad Neta Actualizada
CREATE FUNCTION CalcularUtilidadNeta(@PacienteID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @IngresosTotales DECIMAL(10, 2);
    DECLARE @CostoTotal DECIMAL(10, 2);
    
    -- 1. Calcular ingresos totales (simulados)
    SELECT @IngresosTotales = SUM(CASE
        WHEN P.Estado = 'Resuelto' THEN 100000.00
        ELSE 0.00
    END)
    FROM Pacientes P
    WHERE P.PacienteID = @PacienteID;
    -- 2. Calcular costo total del tratamiento real (desde la tabla Diagnosticos)
    SELECT @CostoTotal = SUM(D.CostoTratamiento)
    FROM Diagnosticos D
    WHERE D.PacienteID = @PacienteID;
    -- 3. Calcular utilidad neta (Ingresos - Costos)
    RETURN @IngresosTotales - ISNULL(@CostoTotal, 0.00);
END;
GO

-- DQL: Uso de la función para obtener la utilidad neta por paciente
SELECT
    P.Nombre AS Paciente,
    P.Estado,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNeta
FROM
    Pacientes P
ORDER BY
    UtilidadNeta DESC;
GO

-- DQL: Listar todos los diagnósticos con detalles del médico
SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    D.Enfermedad,
    CASE D.DiagnosticoFinal
        WHEN 1 THEN 'Final (Correcto)'
        ELSE 'Intento (Error)'
    END AS TipoDiagnostico,
    D.FechaDiagnostico,
    M.Nombre AS NombreMedico,
    M.Especialidad
FROM
    Diagnosticos D
INNER JOIN
    Medicos M ON D.MedicoID = M.MedicoID
INNER JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
ORDER BY
    D.FechaDiagnostico DESC, P.Nombre;
GO

-- DQL: Listar todos los diagnósticos con detalles del paciente y médico
SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    D.Enfermedad,
    D.FechaDiagnostico,
    D.DiagnosticoFinal,
    M.Nombre AS Medico,
    M.Especialidad,
    D.CostoTratamiento,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNetaCalculada
FROM
    Diagnosticos D
JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
JOIN
    Medicos M ON D.MedicoID = M.MedicoID
ORDER BY
    P.Nombre, D.FechaDiagnostico;
GO
-- DQL: Uso de la función en una consulta
SELECT
    P.Nombre,
    P.Estado,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNetaCalculada
FROM
    Pacientes P
WHERE
    P.PacienteID IN (101, 103, 104, 106, 107, 108); -- Ejemplos de pacientes
GO

-- DQL: Listar todos los diagnósticos con detalles del paciente y médico
SELECT
    D.DiagnosticoID,
    P.Nombre AS Paciente,
    D.Enfermedad,
    D.FechaDiagnostico,
    D.DiagnosticoFinal,
    M.Nombre AS Medico,
    M.Especialidad,
    D.CostoTratamiento,
    dbo.CalcularUtilidadNeta(P.PacienteID) AS UtilidadNetaCalculada
FROM
    Diagnosticos D
JOIN
    Pacientes P ON D.PacienteID = P.PacienteID
JOIN
    Medicos M ON D.MedicoID = M.MedicoID
ORDER BY
    P.Nombre, D.FechaDiagnostico;
GO

SELECT
    P.Nombre AS Paciente,
    P.Estado,
    -- Ingresos Totales Simulados
    SUM(CASE
        WHEN P.Estado = 'Resuelto' THEN 100000.00
        ELSE 0.00
    END) AS IngresosTotalesSimulados,
    
    -- Costo Directo del Tratamiento (Simulado como COGS)
    SUM(D.CostoTratamiento) AS CostoDirectoTratamiento,
    
    -- Utilidad Bruta (Ingresos - Costos Directos)
    (
        SUM(CASE
            WHEN P.Estado = 'Resuelto' THEN 100000.00
            ELSE 0.00
        END) - SUM(D.CostoTratamiento)
    ) AS UtilidadBrutaSimulada
FROM
    Pacientes P
INNER JOIN
    Diagnosticos D ON P.PacienteID = D.PacienteID
WHERE
    D.CostoTratamiento IS NOT NULL
GROUP BY
    P.PacienteID, P.Nombre, P.Estado
ORDER BY
    UtilidadBrutaSimulada DESC;
GO


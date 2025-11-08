USE DrHouseMBBD;
GO

PRINT '--- Demostración de 2 Funciones de Ventana ---';

SELECT 
    P.Nombre AS Paciente,
    M.Nombre AS Medico,
    D.Enfermedad,
    D.CostoTratamiento,
    D.FechaDiagnostico,

    -- Ventana A: Ranking del costo (más caro = 1) DENTRO de los casos de ese médico
    RANK() OVER (
        PARTITION BY D.MedicoID 
        ORDER BY D.CostoTratamiento DESC
    ) AS RankingCosto_PorMedico,

    -- Ventana B: Ranking cronológico general (más antiguo = 1)
    ROW_NUMBER() OVER (
        ORDER BY D.FechaDiagnostico ASC
    ) AS RankingCronologico_General
FROM 
    Diagnosticos D
JOIN 
    Medicos M ON D.MedicoID = M.MedicoID
JOIN 
    Pacientes P ON D.PacienteID = P.PacienteID
WHERE
    D.CostoTratamiento IS NOT NULL
ORDER BY
    Medico, RankingCosto_PorMedico;
GO

USE DrHouseMBBD;
GO

PRINT '--- Implementando Jerarquía (SupervisorID) ---';

ALTER TABLE Medicos
ADD SupervisorID INT NULL;
GO

-- Asignar la cadena de mando
UPDATE Medicos SET SupervisorID = 2 WHERE MedicoID = 1;  -- House reporta a Cuddy
UPDATE Medicos SET SupervisorID = 1 WHERE MedicoID IN (4, 5, 6, 7, 8, 9); -- Equipo reporta a House
GO

PRINT '--- Ejecutando CTE Recursiva (Cadena de Mando) ---';

WITH CadenaDeMando AS (
    -- 1. Miembro Ancla (El punto de inicio: Dr. Taub)
    SELECT 
        MedicoID,
        Nombre,
        SupervisorID,
        0 AS NivelJerarquico
    FROM 
        Medicos
    WHERE 
        MedicoID = 7 -- ID de Chris Taub

    UNION ALL

    -- 2. Miembro Recursivo (La consulta que se une a sí misma)
    SELECT 
        M.MedicoID,
        M.Nombre,
        M.SupervisorID,
        C.NivelJerarquico + 1
    FROM 
        Medicos M
    INNER JOIN 
        -- La unión recursiva DEBE usar la clave SupervisorID
        CadenaDeMando C ON M.MedicoID = C.SupervisorID 
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


-- Crear un índice Non-Clustered para búsquedas por nombre
--CREATE NONCLUSTERED INDEX IDX_Pacientes_Nombre
--ON Pacientes (Nombre);
--GO


-- Activar las estadísticas de rendimiento
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

-- ----------------------------------------------------
PRINT '--- Consulta 1: Clustered Index Seek (Mejor rendimiento) ---';
-- Búsqueda por la clave primaria (PacienteID)
-- ----------------------------------------------------
SELECT * FROM Pacientes 
WHERE PacienteID = 104; -- Eve
GO
-- Resultado de IO esperado: Muy pocas lecturas lógicas (ej. 2-3).
-- El plan de ejecución muestra un "Clustered Index Seek".

-- ----------------------------------------------------
PRINT '--- Consulta 2: Non-Clustered Index Seek (Rendimiento alto) ---';
-- Búsqueda por la columna recién indexada (Nombre)
-- ----------------------------------------------------
SELECT * FROM Pacientes 
WHERE Nombre = 'Rebecca Adler';
GO
-- Resultado de IO esperado: Pocas lecturas lógicas (ej. 2-5).
-- El plan de ejecución muestra un "Index Seek" en IDX_Pacientes_Nombre
-- seguido de un "Key Lookup" para obtener el resto de columnas.

-- ----------------------------------------------------
PRINT '--- Consulta 3: Clustered Index Scan (Bajo rendimiento) ---';
-- Búsqueda por una columna no indexada (Episodio)
-- ----------------------------------------------------
SELECT * FROM Pacientes 
WHERE Episodio = 'Piloto';
GO
-- Resultado de IO esperado: Más lecturas lógicas.
-- El plan de ejecución muestra un "Clustered Index Scan",
-- lo que significa que SQL Server tuvo que leer la tabla entera.

-- Desactivar estadísticas
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO


USE DrHouseMBBD;
GO

-- 1. Declarar e inicializar variables
DECLARE @i INT = 1;
DECLARE @TotalInserciones INT = 5;
DECLARE @ID_Base INT = 801; -- Aumentado a 801 para evitar conflictos con ejecuciones anteriores

PRINT 'Iniciando bucle de inserción...';

-- 3. Iniciar el bucle
WHILE @i <= @TotalInserciones
BEGIN
    -- Se añade TRY...CATCH para manejar errores en cada inserción
    BEGIN TRY
        -- 4. Acción: Insertar usando el contador
        INSERT INTO Pacientes (
            PacienteID, 
            Nombre, 
            Episodio, 
            FechaIngreso, 
            Estado
        )
        VALUES (
            @ID_Base + @i, -- Genera ID 802, 803, ...
            'PacientePrueba_' + CAST((@ID_Base + @i) AS VARCHAR(10)),
            'Demo Bucle WHILE',
            GETDATE(),
            'Activo'
        );

        PRINT 'Inserción exitosa: PacienteID ' + CAST((@ID_Base + @i) AS VARCHAR(10));
        
    END TRY
    BEGIN CATCH
        -- Si el INSERT falla (ej. Clave Primaria duplicada), se reporta aquí
        PRINT '--- ERROR AL INSERTAR ID ' + CAST((@ID_Base + @i) AS VARCHAR(10)) + ' ---';
        PRINT ERROR_MESSAGE();
    END CATCH;

    -- 5. Incrementar la variable contador
    SET @i = @i + 1;
END;

PRINT CAST(@TotalInserciones AS VARCHAR(10)) + ' intentos de inserción completados.';
GO

-- 6. Verificación (Buscando los nuevos IDs)
SELECT * FROM Pacientes WHERE PacienteID > 800;
GO



USE DrHouseMBBD;
GO

-- Consulta 1: Búsqueda por columna NO INDEXADA
SELECT 
    PacienteID, 
    MedicoID, 
    Enfermedad
FROM 
    Diagnosticos
WHERE 
    Enfermedad = 'Neurocisticercosis';
GO

USE DrHouseMBBD;
GO

-- Consulta 2: Búsqueda por columna INDEXADA (PK)
SELECT 
    PacienteID, 
    MedicoID, 
    Enfermedad
FROM 
    Diagnosticos
WHERE 
    DiagnosticoID = 1002;
GO

USE DrHouseMBBD;
GO

-- 1. Crear un usuario de base de datos real (ej. 'Usuario_Taub')
-- (Se crea 'WITHOUT LOGIN' solo para fines de esta demostración)
CREATE USER Usuario_Taub WITHOUT LOGIN;
GO

PRINT 'Usuario_Taub creado exitosamente.';

-- 2. Aplicar GRANT al usuario 'Usuario_Taub'
PRINT 'Aplicando GRANT SELECT en Pacientes...';
GRANT SELECT ON Pacientes TO Usuario_Taub;
GO

-- 3. Aplicar DENY al usuario 'Usuario_Taub'
PRINT 'Aplicando DENY UPDATE en Diagnosticos...';
DENY UPDATE ON Diagnosticos TO Usuario_Taub;
GO

-- 4. Aplicar REVOKE al usuario 'Usuario_Taub'
PRINT 'Aplicando REVOKE SELECT en Pacientes...';
REVOKE SELECT ON Pacientes FROM Usuario_Taub;
GO

-- 5. Limpieza (Opcional)
DROP USER Usuario_Taub;



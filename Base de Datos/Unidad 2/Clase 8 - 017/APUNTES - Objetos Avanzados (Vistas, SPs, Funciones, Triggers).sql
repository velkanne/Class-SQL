USE DrHouseMBD;
GO

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

-- DDL: Función de Utilidad Neta (Versión Corregida)
CREATE FUNCTION CalcularUtilidadNeta(@PacienteID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @IngresosTotales DECIMAL(10, 2);
    DECLARE @CostoTotal DECIMAL(10, 2);
    
    SELECT @IngresosTotales = CASE WHEN P.Estado = 'Resuelto' THEN 100000.00 ELSE 0.00 END
    FROM Pacientes P
    WHERE P.PacienteID = @PacienteID;
    
    SELECT @CostoTotal = ISNULL(SUM(D.CostoTratamiento), 0.00)
    FROM Diagnosticos D
    WHERE D.PacienteID = @PacienteID;

    RETURN @IngresosTotales - @CostoTotal;
END;
GO

-- DDL: Procedimiento Almacenado (Versión Corregida)
CREATE PROCEDURE DiagnosticarPaciente
    @p_PacienteID INT,
    @p_MedicoID INT,
    @p_Enfermedad VARCHAR(100),
    @p_EsFinal BIT,
    @p_Costo DECIMAL(10, 2) = NULL
AS
BEGIN
    -- Se inserta el nuevo diagnóstico (no se inserta ID, es IDENTITY)
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
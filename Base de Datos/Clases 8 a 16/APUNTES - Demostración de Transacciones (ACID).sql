USE DrHouseMBD;
GO

-- Demo 1: COMMIT (Éxito)
BEGIN TRANSACTION;
UPDATE Diagnosticos SET DiagnosticoFinal = 1, CostoTratamiento = 25000.00 WHERE DiagnosticoID = 1015;
UPDATE Pacientes SET Estado = 'Resuelto' WHERE PacienteID = 108;
COMMIT TRANSACTION;
GO
-- Verificar COMMIT
SELECT Estado FROM Pacientes WHERE PacienteID = 108; -- Debe ser 'Resuelto'
GO

-- Demo 2: ROLLBACK (Falla)
-- Reiniciar datos
UPDATE Pacientes SET Estado = 'Activo' WHERE PacienteID = 108;
UPDATE Diagnosticos SET DiagnosticoFinal = 0 WHERE DiagnosticoID = 1015;
GO

BEGIN TRANSACTION;
UPDATE Diagnosticos SET DiagnosticoFinal = 1 WHERE DiagnosticoID = 1015;

-- Forzar error de restricción CHECK
BEGIN TRY
    UPDATE Pacientes SET Estado = 'ESTADO_INVALIDO' WHERE PacienteID = 108;
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error de consistencia. Transacción revertida (Atomicidad).';
END CATCH;
GO
-- Verificar ROLLBACK
SELECT Estado FROM Pacientes WHERE PacienteID = 108; -- Debe ser 'Activo'
SELECT DiagnosticoFinal FROM Diagnosticos WHERE DiagnosticoID = 1015; -- Debe ser 0
GO
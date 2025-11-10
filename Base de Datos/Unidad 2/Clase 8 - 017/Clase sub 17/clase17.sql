-- 1. Crear la base de datos
CREATE DATABASE GestionRRHH;
GO

-- 2. Usar la base de datos
USE GestionRRHH;
GO

-- 3. Crear la tabla Departamentos (Mejorada)
CREATE TABLE Departamentos (
    Id_Departamento INT PRIMARY KEY,
    Nombre_Departamento VARCHAR(50) NOT NULL,
    Ubicacion VARCHAR(50),
    
    -- Mejora (Integridad): Evitar departamentos con el mismo nombre
    CONSTRAINT UQ_Nombre_Departamento UNIQUE (Nombre_Departamento)
);
GO

-- 4. Crear la tabla Empleados (Mejorada)
CREATE TABLE Empleados (
    Id_Empleado INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Apellido VARCHAR(100) NOT NULL,
    Salario DECIMAL(10, 2) NOT NULL,
    Fecha_Contratacion DATE NOT NULL,
    Id_Departamento INT,
    
    -- Mejora (Integridad): Salario no puede ser negativo
    CONSTRAINT CHK_Salario_Positivo CHECK (Salario >= 0),
    
    -- Mejora (Integridad): Fecha de contratación no puede ser en el futuro
    CONSTRAINT CHK_Fecha_Contratacion_Valida CHECK (Fecha_Contratacion <= GETDATE()),
    
    -- Mejora (Robustez): Si se elimina el departamento, el empleado queda como NULL
    FOREIGN KEY (Id_Departamento) REFERENCES Departamentos(Id_Departamento)
        ON DELETE SET NULL
);
GO

-- 5. Crear la tabla Proyectos (Mejorada)
CREATE TABLE Proyectos (
    Id_Proyecto INT PRIMARY KEY,
    Nombre_Proyecto VARCHAR(100) NOT NULL,
    Presupuesto DECIMAL(15, 2) NOT NULL,
    Fecha_Inicio DATE,
    Fecha_Fin_Estimada DATE,
    
    -- Mejora (Integridad): Evitar proyectos con el mismo nombre
    CONSTRAINT UQ_Nombre_Proyecto UNIQUE (Nombre_Proyecto),
    
    -- Mejora (Integridad): Presupuesto no puede ser negativo
    CONSTRAINT CHK_Presupuesto_Positivo CHECK (Presupuesto >= 0),
    
    -- Mejora (Integridad): La fecha de fin debe ser posterior a la de inicio
    CONSTRAINT CHK_Fechas_Proyecto_Logicas CHECK (Fecha_Fin_Estimada >= Fecha_Inicio)
);
GO

-- 6. Crear la tabla Asignaciones (Mejorada)
CREATE TABLE Asignaciones (
    Id_Empleado INT,
    Id_Proyecto INT,
    Fecha_Asignacion DATE NOT NULL,
    Horas_Dedicadas INT,
    
    PRIMARY KEY (Id_Empleado, Id_Proyecto), -- Clave Compuesta
    
    -- Mejora (Integridad): Horas no pueden ser negativas
    CONSTRAINT CHK_Horas_Positivas CHECK (Horas_Dedicadas >= 0),
    
    -- Mejora (Robustez): Si se elimina el Empleado, la asignación se borra
    FOREIGN KEY (Id_Empleado) REFERENCES Empleados(Id_Empleado)
        ON DELETE CASCADE,
        
    -- Mejora (Robustez): Si se elimina el Proyecto, la asignación se borra
    FOREIGN KEY (Id_Proyecto) REFERENCES Proyectos(Id_Proyecto)
        ON DELETE CASCADE
);
GO

-- 7. Crear Índices (Mejora de Rendimiento)
CREATE INDEX IX_Empleados_NombreCompleto ON Empleados (Apellido, Nombre);
CREATE INDEX IX_Empleados_Departamento ON Empleados (Id_Departamento);
GO

-- 8. Inserción de Datos (Sin cambios)
INSERT INTO Departamentos (Id_Departamento, Nombre_Departamento, Ubicacion) VALUES
(1, 'IT', 'Piso 1'), (2, 'Ventas', 'Piso 2'), (3, 'Finanzas', 'Piso 3'), (4, 'Recursos Humanos', 'Piso 4');
GO

INSERT INTO Empleados (Id_Empleado, Nombre, Apellido, Salario, Fecha_Contratacion, Id_Departamento) VALUES
(101, 'Ana', 'Gomez', 75000.00, '2022-01-15', 1),
(102, 'Juan', 'Perez', 60000.00, '2023-05-20', 2),
(103, 'Maria', 'Lopez', 85000.00, '2021-11-01', 1),
(104, 'Carlos', 'Ruiz', 55000.00, '2024-03-10', 3),
(105, 'Sofía', 'Castro', 72000.00, '2023-09-01', 2);
GO

INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto, Fecha_Inicio, Fecha_Fin_Estimada) VALUES
(1, 'Migracion a la Nube', 250000.00, '2024-06-01', '2024-12-31'),
(2, 'Campaña Digital Q4', 80000.00, '2024-10-01', '2024-11-30'),
(3, 'Auditoria Interna 2024', 50000.00, '2024-09-01', '2024-10-31');
GO

INSERT INTO Asignaciones (Id_Empleado, Id_Proyecto, Fecha_Asignacion, Horas_Dedicadas) VALUES
(101, 1, '2024-06-01', 300),
(103, 1, '2024-06-01', 300),
(102, 2, '2024-10-01', 150),
(105, 2, '2024-10-01', 150),
(104, 3, '2024-09-01', 200);
GO

-- 1. Verificar el estado inicial
-- (Ana Gomez, ID 101, Salario 75000.00)
SELECT Nombre, Apellido, Salario 
FROM Empleados 
WHERE Id_Empleado = 101;
GO

-- 2. Iniciar la transacción
BEGIN TRANSACTION;

BEGIN TRY
    -- Operación 1: Aumentar el salario de Ana (Éxito temporal)
    UPDATE Empleados
    SET Salario = 80000.00
    WHERE Id_Empleado = 101;

    PRINT 'Paso 1: Salario actualizado temporalmente (dentro de la transacción).';

    -- Operación 2: Asignar a Ana a un proyecto inválido (ID 999)
    -- Esto fallará debido a la restricción FOREIGN KEY
    INSERT INTO Asignaciones (Id_Empleado, Id_Proyecto, Fecha_Asignacion, Horas_Dedicadas)
    VALUES (101, 999, GETDATE(), 100);

    -- Si ambas operaciones tuvieran éxito, se confirmaría
    COMMIT TRANSACTION;
    PRINT 'Transacción confirmada (esto no debería ocurrir).';

END TRY
BEGIN CATCH
    -- Capturar el error
    PRINT '--- ¡Error detectado! ---';
    PRINT ERROR_MESSAGE();
    
    -- Revertir TODA la transacción
    ROLLBACK TRANSACTION;
    PRINT '--- Transacción revertida (ROLLBACK ejecutado). ---';
END CATCH;
GO

-- 3. Verificar el estado final
-- El salario debe haber vuelto a 75000.00 gracias al ROLLBACK.
SELECT Nombre, Apellido, Salario 
FROM Empleados 
WHERE Id_Empleado = 101;
GO

-- Verificación del UPDATE exitoso fuera de la transacción fallida
-- Reiniciar el salario a su valor original para la prueba
-- 1. Verificar el salario inicial de Ana Gomez
SELECT Nombre, Apellido, Salario 
FROM Empleados 
WHERE Id_Empleado = 101;

-- 2. Ejecutar el UPDATE
UPDATE Empleados
SET Salario = 80000.00
WHERE Id_Empleado = 101;

-- 3. Verificar el salario final
SELECT Nombre, Apellido, Salario 
FROM Empleados 
WHERE Id_Empleado = 101;
GO

-- Verificación del UPDATE con JOIN
-- Reiniciar los salarios de los empleados del departamento 'IT' para la prueba
-- 1. Verificar salarios iniciales del departamento 'IT'
SELECT E.Nombre, E.Salario, D.Nombre_Departamento
FROM Empleados E
JOIN Departamentos D ON E.Id_Departamento = D.Id_Departamento
WHERE D.Nombre_Departamento = 'IT';

-- 2. Ejecutar el UPDATE (Sintaxis T-SQL con JOIN)
UPDATE E
SET E.Salario = E.Salario * 1.10 -- Aumento del 10%
FROM Empleados E
JOIN Departamentos D ON E.Id_Departamento = D.Id_Departamento
WHERE D.Nombre_Departamento = 'IT';

-- 3. Verificar los salarios finales
SELECT E.Nombre, E.Salario, D.Nombre_Departamento
FROM Empleados E
JOIN Departamentos D ON E.Id_Departamento = D.Id_Departamento
WHERE D.Nombre_Departamento = 'IT';
GO



-- Verificación de la restricción CHECK al intentar asignar un salario negativo
-- Reiniciar el salario de Ana Gomez para la prueba
PRINT 'Intentando asignar un salario negativo...';

-- Esta sentencia fallará y será revertida automáticamente
BEGIN TRY
    UPDATE Empleados
    SET Salario = -500.00
    WHERE Id_Empleado = 104; -- Carlos Ruiz
END TRY
BEGIN CATCH
    PRINT '--- ¡Error detectado! ---';
    PRINT ERROR_MESSAGE();
    PRINT 'El salario no fue actualizado.';
END CATCH;

-- Verificar que el salario de Carlos Ruiz no cambió
SELECT Nombre, Salario FROM Empleados WHERE Id_Empleado = 104;
GO
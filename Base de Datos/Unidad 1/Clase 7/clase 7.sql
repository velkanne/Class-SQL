-- Verificar y eliminar la base de datos si ya existe para evitar errores
IF DB_ID('EmpresaEjemplo') IS NOT NULL
    DROP DATABASE EmpresaEjemplo;
GO

-- 1. Crear la base de datos del proyecto
CREATE DATABASE EmpresaEjemplo;
GO

-- 2. Usar la base de datos recién creada
USE EmpresaEjemplo;
GO

-- 3. Crear la tabla de Departamentos (Tabla Padre)
CREATE TABLE Departamentos (
    Id_Depto INT PRIMARY KEY,
    Nombre_Depto NVARCHAR(50) NOT NULL
);
GO

-- 4. Crear la tabla de Empleados (Tabla Hija)
CREATE TABLE Empleados (
    Id_Empleado INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Salario DECIMAL(10, 2),
    Id_Depto INT,
    FechaContratacion DATE,
    CONSTRAINT FK_Depto
        FOREIGN KEY (Id_Depto)
        REFERENCES Departamentos (Id_Depto)
);
GO

-- 5. Crear la tabla de Proyectos (Tabla Relacionada)
CREATE TABLE Proyectos (
    Id_Proyecto INT PRIMARY KEY,
    Nombre_Proyecto NVARCHAR(100) NOT NULL,
    Presupuesto DECIMAL(12, 2)
);
GO

-- 6. Crear una tabla de relación N:M entre Empleados y Proyectos
CREATE TABLE EmpleadosProyectos (
    Id_Empleado INT,
    Id_Proyecto INT,
    HorasTrabajadas INT,
    CONSTRAINT PK_EmpleadosProyectos PRIMARY KEY (Id_Empleado, Id_Proyecto),
    CONSTRAINT FK_Empleado
        FOREIGN KEY (Id_Empleado)
        REFERENCES Empleados (Id_Empleado),
    CONSTRAINT FK_Proyecto
        FOREIGN KEY (Id_Proyecto)
        REFERENCES Proyectos (Id_Proyecto)
);
GO

-- 7. Insertar datos en la tabla Departamentos (5 registros)
INSERT INTO Departamentos (Id_Depto, Nombre_Depto) VALUES (1, 'Ventas');
INSERT INTO Departamentos (Id_Depto, Nombre_Depto) VALUES (2, 'Marketing');
INSERT INTO Departamentos (Id_Depto, Nombre_Depto) VALUES (3, 'Tecnología');
INSERT INTO Departamentos (Id_Depto, Nombre_Depto) VALUES (4, 'Recursos Humanos');
INSERT INTO Departamentos (Id_Depto, Nombre_Depto) VALUES (5, 'Finanzas');
GO

-- 8. Insertar 100 registros en la tabla Empleados
DECLARE @i INT = 1;
WHILE @i <= 100
BEGIN
    INSERT INTO Empleados (Id_Empleado, Nombre, Salario, Id_Depto, FechaContratacion) 
    VALUES (@i, 'Empleado ' + CAST(@i AS NVARCHAR(3)), 
            40000 + (RAND() * 60000), 
            CAST((RAND() * 4) + 1 AS INT), 
            DATEADD(day, -CAST(RAND() * 1000 AS INT), GETDATE()));
    SET @i = @i + 1;
END;
GO

-- 9. Insertar 10 registros en la tabla Proyectos
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (101, 'Plataforma E-commerce', 250000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (102, 'Campaña Digital 2024', 80000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (103, 'Migración a la Nube', 350000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (104, 'Análisis de Mercado', 45000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (105, 'Sistema de RRHH', 150000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (106, 'App Móvil', 200000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (107, 'Optimización de Ciberseguridad', 110000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (108, 'Plan de Contingencia', 60000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (109, 'Inventario Logístico', 95000.00);
INSERT INTO Proyectos (Id_Proyecto, Nombre_Proyecto, Presupuesto) VALUES (110, 'Programa de Capacitación', 55000.00);
GO

-- 10. Insertar más de 100 registros en la tabla EmpleadosProyectos
DECLARE @j INT = 1;
WHILE @j <= 150
BEGIN
        -- Cambio: Se agrego un comentario para explicar la funcionalidad de la sentencia INSERT.
    -- La siguiente sentencia inserta un registro aleatorio en la tabla EmpleadosProyectos.
    INSERT INTO EmpleadosProyectos (Id_Empleado, Id_Proyecto, HorasTrabajadas)
    VALUES (CAST((RAND() * 99) + 1 AS INT), 
            CAST((RAND() * 9) + 101 AS INT), 
            CAST(RAND() * 200 AS INT) + 20);
    SET @j = @j + 1;
END;
GO


-- 1. Obtener la lista de todos los empleados y su salario
SELECT
    Nombre,
    Salario
FROM Empleados;

-- 2. Encontrar todos los empleados que trabajan en el departamento de 'Tecnología'
SELECT
    e.Nombre,
    e.FechaContratacion
FROM Empleados AS e
INNER JOIN Departamentos AS d
    ON e.Id_Depto = d.Id_Depto
WHERE d.Nombre_Depto = 'Tecnología';

-- 3. Calcular el salario promedio por departamento
SELECT
    d.Nombre_Depto,
    AVG(e.Salario) AS Salario_Promedio
FROM Empleados AS e
INNER JOIN Departamentos AS d
    ON e.Id_Depto = d.Id_Depto
GROUP BY
    d.Nombre_Depto;

-- 4. Contar cuántos empleados trabajan en cada proyecto
SELECT
    p.Nombre_Proyecto,
    COUNT(ep.Id_Empleado) AS Total_Empleados
FROM EmpleadosProyectos AS ep
INNER JOIN Proyectos AS p
    ON ep.Id_Proyecto = p.Id_Proyecto
GROUP BY
    p.Nombre_Proyecto;

-- 5. Obtener una lista de empleados y sus proyectos, incluyendo las horas trabajadas
SELECT
    e.Nombre AS Nombre_Empleado,
    p.Nombre_Proyecto,
    ep.HorasTrabajadas
FROM EmpleadosProyectos AS ep
INNER JOIN Empleados AS e
    ON ep.Id_Empleado = e.Id_Empleado
INNER JOIN Proyectos AS p
    ON ep.Id_Proyecto = p.Id_Proyecto
ORDER BY
    e.Nombre;

SELECT Nombre, Id_Depto
FROM Empleados
WHERE Id_Depto = 1 OR Id_Depto = 2;

SELECT Nombre 
FROM Empleados 
WHERE Salario > 60000 AND Id_Depto = 1;

-- OPCION A, USANDO OR 
SELECT * 
FROM Empleados 
WHERE Id_Depto = 1 OR Id_Depto = 2;

-- OPCION B, USANDO IN 
SELECT * 
FROM Empleados 
WHERE Id_Depto IN (1, 2);

SELECT Nombre, Salario 
FROM Empleados 
WHERE Id_Depto <> 3 AND Salario < 50000;

-- OPCION A, USANDO AND 
SELECT * 
FROM Proyectos 
WHERE Presupuesto >= 150000 AND Presupuesto <= 300000

-- OPCION B, USANDO BETWEEN
SELECT * 
FROM Proyectos 
WHERE Presupuesto BETWEEN 150000 AND 300000;

SELECT * FROM Empleados 
WHERE YEAR(FechaContratacion) <> 2023;

SELECT Nombre, Salario, FechaContratacion 
FROM Empleados 
WHERE Salario > 70000 AND FechaContratacion > '2022-01-01';

SELECT TOP 1 Nombre, Salario 
FROM Empleados 
ORDER BY Salario DESC;

SELECT Nombre_Depto 
FROM Departamentos 
WHERE Id_Depto = 4;

SELECT E.Nombre, D.Nombre_Depto 
FROM Empleados E
JOIN Departamentos D
ON E.Id_Depto = D.Id_Depto;

SELECT A.Nombre, F.Nombre_Depto
FROM Empleados A
JOIN Departamentos F
ON A.Id_Depto = F.Id_Depto;

SELECT E.Nombre, P.Nombre_Proyecto
FROM Empleados E
JOIN EmpleadosProyectos EP
ON E.Id_Empleado = EP.Id_Empleado
JOIN Proyectos P
ON EP.Id_Proyecto = P.Id_Proyecto;

SELECT Nombre, Salario
FROM Empleados
ORDER BY Salario DESC;

SELECT TOP 10 Nombre, Salario
FROM Empleados 
ORDER BY Salario DESC;

SELECT *
FROM Empleados
WHERE Id_Depto = 3
ORDER BY FechaContratacion DESC;

SELECT Id_Depto, COUNT(*) AS TotalEmpleados
FROM Empleados
GROUP BY Id_Depto;

SELECT Id_Depto, AVG(Salario) AS SalarioPromedio
From Empleados
GROUP BY Id_Depto;

SELECT SUM(Presupuesto) AS PresupuestoTotal
FROM Proyectos;


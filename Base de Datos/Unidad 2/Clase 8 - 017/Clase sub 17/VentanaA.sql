USE GestionRRHH;
GO

SELECT 
    Nombre,
    Apellido,
    Salario,
    D.Nombre_Departamento,
    
    -- Ventana A: Promedio del salario, particionado por departamento
    AVG(E.Salario) OVER (PARTITION BY E.Id_Departamento) AS Promedio_Departamento,
    
    -- Ventana B: Promedio del salario de toda la tabla (sin partición)
    AVG(E.Salario) OVER () AS Promedio_Empresa
FROM 
    Empleados E
JOIN 
    Departamentos D ON E.Id_Departamento = D.Id_Departamento;
GO



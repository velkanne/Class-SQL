USE GestionRRHH;
GO

SELECT 
    Nombre,
    Apellido,
    Salario,
    Fecha_Contratacion,
    D.Nombre_Departamento,
    
    -- Ventana A: Ranking de salario (más alto primero) dentro de su departamento
    DENSE_RANK() OVER (PARTITION BY E.Id_Departamento 
                       ORDER BY E.Salario DESC) AS Ranking_Salario_Depto,
    
    -- Ventana B: Ranking de antigüedad (más antiguo primero) en toda la empresa
    ROW_NUMBER() OVER (ORDER BY E.Fecha_Contratacion ASC) AS Antiguedad_General
FROM 
    Empleados E
JOIN 
    Departamentos D ON E.Id_Departamento = D.Id_Departamento;
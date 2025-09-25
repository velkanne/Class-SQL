-- Verificar y eliminar la base de datos si ya existe para evitar errores
IF DB_ID('HospitalPrincetonPlainsboro') IS NOT NULL
BEGIN
    ALTER DATABASE HospitalPrincetonPlainsboro SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE HospitalPrincetonPlainsboro;
END
GO

-- 1. Crear la base de datos del consultorio
CREATE DATABASE HospitalPrincetonPlainsboro;
GO

-- 2. Usar la base de datos recién creada
USE HospitalPrincetonPlainsboro;
GO

-- 3. Crear la tabla de Departamentos Medicos (Tabla Padre)
CREATE TABLE DepartamentosMedicos (
    Id_Depto INT PRIMARY KEY,
    Nombre_Depto NVARCHAR(50) NOT NULL
);
GO

-- 4. Crear la tabla de Medicos (Tabla Hija)
CREATE TABLE Medicos (
    Id_Medico INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    Especialidad NVARCHAR(100),
    Id_Depto INT,
    FechaContratacion DATE,
    CONSTRAINT FK_DeptoMedico
        FOREIGN KEY (Id_Depto)
        REFERENCES DepartamentosMedicos (Id_Depto)
);
GO

-- 5. Crear la tabla de Casos Medicos (Tabla Relacionada)
CREATE TABLE CasosMedicos (
    Id_Caso INT PRIMARY KEY,
    Nombre_Caso NVARCHAR(100) NOT NULL,
    Descripcion NVARCHAR(500)
);
GO

-- 6. Crear una tabla de relación N:M entre Medicos y Casos Medicos
CREATE TABLE MedicosCasos (
    Id_Medico INT,
    Id_Caso INT,
    Rol NVARCHAR(100),
    CONSTRAINT PK_MedicosCasos PRIMARY KEY (Id_Medico, Id_Caso),
    CONSTRAINT FK_MedicoCaso
        FOREIGN KEY (Id_Medico)
        REFERENCES Medicos (Id_Medico),
    CONSTRAINT FK_CasoMedico
        FOREIGN KEY (Id_Caso)
        REFERENCES CasosMedicos (Id_Caso)
);
GO

-- 7. Insertar datos en la tabla DepartamentosMedicos (5 registros)
INSERT INTO DepartamentosMedicos (Id_Depto, Nombre_Depto) VALUES (1, 'Diagnóstico Médico');
INSERT INTO DepartamentosMedicos (Id_Depto, Nombre_Depto) VALUES (2, 'Cardiología');
INSERT INTO DepartamentosMedicos (Id_Depto, Nombre_Depto) VALUES (3, 'Neurología');
INSERT INTO DepartamentosMedicos (Id_Depto, Nombre_Depto) VALUES (4, 'Oncología');
INSERT INTO DepartamentosMedicos (Id_Depto, Nombre_Depto) VALUES (5, 'Inmunología');
GO

-- 8. Insertar registros en la tabla Medicos
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (1, 'Dr. Gregory House', 'Nefrólogo, Infectólogo', 1, '1995-04-10');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (2, 'Dr. Eric Foreman', 'Neurólogo', 1, '2004-11-16');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (3, 'Dr. Allison Cameron', 'Inmunóloga', 1, '2004-11-16');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (4, 'Dr. Robert Chase', 'Intensivista, Cirujano', 1, '2004-11-16');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (5, 'Dr. Lisa Cuddy', 'Endocrinóloga', 1, '1990-07-01');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (6, 'Dr. James Wilson', 'Oncólogo', 4, '1992-09-15');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (7, 'Dr. Lawrence Kutner', 'Medicina deportiva', 1, '2007-09-25');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (8, 'Dr. Remy "Thirteen" Hadley', 'Internista', 1, '2007-09-25');
INSERT INTO Medicos (Id_Medico, Nombre, Especialidad, Id_Depto, FechaContratacion) VALUES (9, 'Dr. Chris Taub', 'Cirujano Plástico', 1, '2007-09-25');
GO

-- 9. Insertar 10 registros en la tabla CasosMedicos
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (101, 'Paciente con fiebre y erupción', 'Fiebre persistente, erupción cutánea que no responde a antibióticos.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (102, 'Parálisis facial súbita', 'Hombre de 45 años con parálisis en un lado de la cara.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (103, 'Dolor abdominal agudo', 'Dolor intenso en el cuadrante inferior derecho, sospecha de apendicitis atípica.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (104, 'Pérdida de memoria a corto plazo', 'Mujer joven con episodios de amnesia.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (105, 'Convulsiones recurrentes', 'Niño de 10 años con convulsiones sin causa aparente.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (106, 'Insuficiencia respiratoria', 'Paciente con dificultad para respirar, radiografía de tórax inusual.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (107, 'Síndrome de fatiga crónica', 'Fatiga extrema que no mejora con el descanso.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (108, 'Visión doble y debilidad muscular', 'Síntomas neurológicos que sugieren una enfermedad autoinmune.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (109, 'Arritmia cardíaca severa', 'Paciente con ritmo cardíaco irregular y peligroso.');
INSERT INTO CasosMedicos (Id_Caso, Nombre_Caso, Descripcion) VALUES (110, 'Reacción alérgica desconocida', 'Anafilaxia recurrente sin un alérgeno identificado.');
GO

-- 10. Insertar registros en la tabla MedicosCasos
-- House y su equipo en varios casos
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (1, 101, 'Líder de Diagnóstico');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (2, 101, 'Diagnóstico Diferencial');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (3, 101, 'Inmunología');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (4, 101, 'Cuidados Intensivos');

INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (1, 102, 'Líder de Diagnóstico');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (2, 102, 'Neurología');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (8, 102, 'Medicina Interna');

INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (1, 103, 'Líder de Diagnóstico');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (4, 103, 'Cirugía');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (9, 103, 'Cirugía Plástica');

INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (6, 104, 'Consulta Oncológica');
INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol) VALUES (1, 104, 'Líder de Diagnóstico');

-- Asignaciones adicionales aleatorias
DECLARE @k INT = 1;
WHILE @k <= 20
BEGIN
    INSERT INTO MedicosCasos (Id_Medico, Id_Caso, Rol)
    VALUES (CAST((RAND() * 8) + 2 AS INT), 
            CAST((RAND() * 9) + 101 AS INT), 
            'Consultor');
    SET @k = @k + 1;
END;
GO


-- 1. Listar todos los médicos y sus especialidades
SELECT
    Id_Medico,
    Nombre,
    Especialidad,
    FechaContratacion
FROM Medicos;

-- 2. Encontrar todos los médicos del departamento de 'Diagnóstico Médico'
SELECT
    m.Nombre AS Nombre_Medico,
    m.Especialidad
FROM Medicos AS m
INNER JOIN DepartamentosMedicos AS d
    ON m.Id_Depto = d.Id_Depto
WHERE d.Nombre_Depto = 'Diagnóstico Médico';

-- 3. Contar cuántos médicos hay por cada departamento
SELECT
    d.Nombre_Depto,
    COUNT(m.Id_Medico) AS Total_Medicos
FROM Medicos AS m
INNER JOIN DepartamentosMedicos AS d
    ON m.Id_Depto = d.Id_Depto
GROUP BY
    d.Nombre_Depto;

-- 4. Encontrar los casos médicos en los que un médico específico ha participado
-- En este caso, buscamos al Dr. Gregory House (Id_Medico = 1)
SELECT
    cm.Nombre_Caso,
    mc.Rol
FROM CasosMedicos AS cm
INNER JOIN MedicosCasos AS mc
    ON cm.Id_Caso = mc.Id_Caso
WHERE mc.Id_Medico = 1;

-- 5. Obtener una lista completa de los médicos y sus roles en todos los casos
SELECT
    m.Nombre AS Nombre_Medico,
    c.Nombre_Caso AS Nombre_Caso,
    mc.Rol
FROM MedicosCasos AS mc
INNER JOIN Medicos AS m
    ON mc.Id_Medico = m.Id_Medico
INNER JOIN CasosMedicos AS c
    ON mc.Id_Caso = c.Id_Caso
ORDER BY
    m.Nombre;

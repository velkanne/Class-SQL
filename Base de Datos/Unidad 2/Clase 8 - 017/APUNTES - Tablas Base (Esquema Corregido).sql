USE DrHouseMBD;
GO

-- 1. Tabla Medicos
CREATE TABLE Medicos (
    MedicoID INT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Especialidad VARCHAR(50) NOT NULL,
    EsJefe INT DEFAULT 0
);

-- 2. Tabla Pacientes
CREATE TABLE Pacientes (
    PacienteID INT PRIMARY KEY,
    Nombre VARCHAR(100) NOT NULL,
    Episodio VARCHAR(100) NOT NULL,
    FechaIngreso DATE NOT NULL,
    Estado VARCHAR(20) CHECK (Estado IN ('Activo', 'Resuelto', 'Fallecido'))
);

-- 3. Tabla Diagnosticos (Esquema Corregido y Unificado)
CREATE TABLE Diagnosticos (
    DiagnosticoID INT PRIMARY KEY IDENTITY(1001, 1), -- Mejora: Clave autoincremental
    PacienteID INT NOT NULL,
    MedicoID INT NOT NULL,
    FechaDiagnostico DATE NOT NULL,
    DiagnosticoFinal INT NOT NULL,
    Enfermedad VARCHAR(100) NOT NULL,
    CostoTratamiento DECIMAL(10, 2), -- Columna añadida desde el inicio
    
    FOREIGN KEY (PacienteID) REFERENCES Pacientes(PacienteID),
    FOREIGN KEY (MedicoID) REFERENCES Medicos(MedicoID)
);
GO


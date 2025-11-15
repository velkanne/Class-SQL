USE DrHouseMBD;
GO

-- Demo 1FN
CREATE TABLE Demo_PacientesNormalizados (
    PacienteID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    DoctorAsignado NVARCHAR(100)
);
CREATE TABLE Demo_Recetas (
    RecetaID INT PRIMARY KEY IDENTITY(1, 1),
    PacienteID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50),
    FOREIGN KEY (PacienteID) REFERENCES Demo_PacientesNormalizados(PacienteID)
);
INSERT INTO Demo_PacientesNormalizados VALUES (1, 'John Doe', 'Dr. House'), (2, 'Jane Smith', 'Dr. Cuddy');
INSERT INTO Demo_Recetas (PacienteID, Medicamento, Dosis) VALUES (1, 'Ibuprofeno', '200mg'), (1, 'Paracetamol', '500mg');
GO

-- Demo 2FN
CREATE TABLE Demo_DiagnosticosDetalleMal (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Enfermedad NVARCHAR(100) NOT NULL,
    MedicoAsignado NVARCHAR(50),
    PRIMARY KEY (DiagnosticoID, Medicamento)
);
INSERT INTO Demo_DiagnosticosDetalleMal VALUES (1002, 'Albendazol', 'Neurocisticercosis', 'Dr. House'), (1002, 'Dexametasona', 'Neurocisticercosis', 'Dr. House');
GO
CREATE TABLE Demo_DiagnosticosCabecera_2FN (
    DiagnosticoID INT PRIMARY KEY,
    Enfermedad NVARCHAR(100) NOT NULL,
    MedicoAsignado NVARCHAR(50) NOT NULL
);
CREATE TABLE Demo_RecetasDetalle_2FN (
    DiagnosticoID INT NOT NULL,
    Medicamento NVARCHAR(100) NOT NULL,
    Dosis NVARCHAR(50),
    PRIMARY KEY (DiagnosticoID, Medicamento),
    FOREIGN KEY (DiagnosticoID) REFERENCES Demo_DiagnosticosCabecera_2FN(DiagnosticoID)
);
INSERT INTO Demo_DiagnosticosCabecera_2FN VALUES (1002, 'Neurocisticercosis', 'Dr. House');
INSERT INTO Demo_RecetasDetalle_2FN (DiagnosticoID, Medicamento, Dosis) VALUES (1002, 'Albendazol', '400mg'), (1002, 'Dexametasona', '2mg');
GO

-- Demo 3FN
CREATE TABLE Demo_Lenguajes (
    IdiomaID INT PRIMARY KEY,
    IdiomaNombre NVARCHAR(50) NOT NULL
);
CREATE TABLE Demo_Medicos_Lenguajes (
    MedicoID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL,
    IdiomaID INT NOT NULL,
    FOREIGN KEY (IdiomaID) REFERENCES Demo_Lenguajes(IdiomaID)
);
INSERT INTO Demo_Lenguajes VALUES (1, 'Inglés'), (2, 'Francés'), (3, 'Español'), (4, 'Alemán');
INSERT INTO Demo_Medicos_Lenguajes VALUES (1, 'Dr. House', 1), (3, 'Dr. Wilson', 1), (7, 'Dr. Taub', 3);
GO

-- Demo 4FN
CREATE TABLE Demo_Medicos_4FN (
    MedicoID INT PRIMARY KEY,
    Nombre NVARCHAR(100) NOT NULL
);
CREATE TABLE Demo_MedicoEspecialidad (
    MedicoID INT NOT NULL,
    Especialidad NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MedicoID, Especialidad),
    FOREIGN KEY (MedicoID) REFERENCES Demo_Medicos_4FN(MedicoID)
);
CREATE TABLE Demo_MedicoCertificacion (
    MedicoID INT NOT NULL,
    Certificacion NVARCHAR(50) NOT NULL,
    PRIMARY KEY (MedicoID, Certificacion),
    FOREIGN KEY (MedicoID) REFERENCES Demo_Medicos_4FN(MedicoID)
);
INSERT INTO Demo_Medicos_4FN VALUES (3, 'Dr. Wilson'), (6, 'Dr. Chase');
INSERT INTO Demo_MedicoEspecialidad VALUES (3, 'Oncología'), (3, 'Cuidados Paliativos'), (6, 'Cuidados Intensivos');
INSERT INTO Demo_MedicoCertificacion VALUES (3, 'Radioterapia'), (3, 'Manejo del Dolor'), (6, 'Trasplantes');
GO

-- Demo 5FN
CREATE TABLE Demo_MedicoDiagnostico_5FN (MedicoID INT NOT NULL, DiagnosticoID INT NOT NULL, PRIMARY KEY (MedicoID, DiagnosticoID));
CREATE TABLE Demo_DiagnosticoMedicamento_5FN (DiagnosticoID INT NOT NULL, Medicamento NVARCHAR(100) NOT NULL, PRIMARY KEY (DiagnosticoID, Medicamento));
CREATE TABLE Demo_MedicoMedicamento_5FN (MedicoID INT NOT NULL, Medicamento NVARCHAR(100) NOT NULL, PRIMARY KEY (MedicoID, Medicamento));
GO
INSERT INTO Demo_MedicoDiagnostico_5FN VALUES (5, 1023), (6, 1024), (8, 1025);
INSERT INTO Demo_DiagnosticoMedicamento_5FN VALUES (1023, 'Ciclofosfamida'), (1024, 'Antiácido'), (1025, 'Propranolol');
INSERT INTO Demo_MedicoMedicamento_5FN VALUES (5, 'Ciclofosfamida'), (6, 'Antiácido'), (8, 'Propranolol');
GO
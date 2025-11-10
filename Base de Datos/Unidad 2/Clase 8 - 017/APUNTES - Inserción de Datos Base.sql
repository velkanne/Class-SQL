USE DrHouseMBD;
GO

-- DML: Medicos (Datos combinados)
INSERT INTO Medicos (MedicoID, Nombre, Especialidad, EsJefe) VALUES
(1, 'Gregory House', 'Nefrología/Infecciosas', 1),
(2, 'Lisa Cuddy', 'Endocrinología', 1),
(3, 'James Wilson', 'Oncología', 0),
(4, 'Eric Foreman', 'Neurología', 0),
(5, 'Allison Cameron', 'Inmunología', 0),
(6, 'Robert Chase', 'Cuidados Intensivos', 0),
(7, 'Chris Taub', 'Cirugía Plástica', 0),
(8, 'Thirteen (Remy Hadley)', 'Medicina Interna', 0),
(9, 'Lawrence Kutner', 'Medicina del Deporte', 0);
GO

-- DML: Pacientes (Datos combinados)
INSERT INTO Pacientes (PacienteID, Nombre, Episodio, FechaIngreso, Estado) VALUES
(101, 'Rebecca Adler', 'Piloto', '2004-11-16', 'Resuelto'),
(102, 'John Henry Giles', 'El Caso de la Esclava', '2005-01-25', 'Resuelto'),
(103, 'Steve McQueen', 'Un Mundo Feliz', '2006-03-28', 'Fallecido'),
(104, 'Eve', 'Misterios de la Vida', '2007-05-08', 'Activo'),
(106, 'Steve', 'La Causa Final', '2008-05-19', 'Fallecido'),
(107, 'Jeff', 'Un Gran Chico', '2009-02-09', 'Resuelto'),
(108, 'Abby', 'Espejismo', '2010-01-25', 'Activo'),
(109, 'Mike Stone', 'Inocencia Perdida', '2023-08-01', 'Resuelto'),
(110, 'Laura Brandt', 'El Cerebro de la Bestia', '2023-09-15', 'Activo'),
(111, 'Gary Evans', 'Ve a Saber', '2023-10-20', 'Resuelto'),
(112, 'Helen Cox', 'Amo mi Vida', '2023-11-05', 'Activo'),
(113, 'Daniel Flynn', 'El Corazón del Demonio', '2023-12-10', 'Resuelto'),
(114, 'Sara Lee', 'Toda la Verdad', '2024-01-05', 'Fallecido');
GO

-- DML: Diagnosticos (Datos combinados)
SET IDENTITY_INSERT Diagnosticos ON;
INSERT INTO Diagnosticos (DiagnosticoID, PacienteID, MedicoID, FechaDiagnostico, DiagnosticoFinal, Enfermedad, CostoTratamiento) VALUES
(1001, 101, 4, '2004-11-17', 0, 'Esclerosis Múltiple (Intento)', 5000.00),
(1002, 101, 1, '2004-11-18', 1, 'Neurocisticercosis', 45000.00),
(1003, 102, 5, '2005-01-26', 0, 'Poliarteritis Nodosa (Intento)', 8000.00),
(1004, 102, 1, '2005-01-28', 1, 'Tripanosomiasis Africana', 30000.00),
(1005, 103, 6, '2006-03-29', 0, 'Hipertensión Pulmonar (Intento)', 12000.00),
(1006, 103, 1, '2006-03-30', 1, 'Ántrax por Inhalación', 60000.00),
(1007, 104, 1, '2007-05-09', 0, 'Encefalitis por Anticuerpos (Intento)', 9000.00),
(1010, 104, 7, '2009-01-01', 0, 'Hipocondría inducida', 5000.00),
(1011, 106, 9, '2008-05-20', 0, 'Rabia (Intento)', 8000.00),
(1012, 106, 1, '2008-05-21', 1, 'Tuberculosis Multidrogorresistente', 75000.00),
(1013, 107, 8, '2009-02-10', 0, 'Síndrome de Cushing (Intento)', 6000.00),
(1014, 107, 7, '2009-02-12', 1, 'Sarcoma de Ewing', 55000.00),
(1015, 108, 1, '2010-01-26', 0, 'Fiebre Q', 1000.00),
(1023, 109, 5, GETDATE(), 1, 'Vasculitis de Churg-Strauss', 30000.00),
(1024, 110, 6, GETDATE(), 1, 'Mononucleosis', 500.00),
(1025, 111, 8, GETDATE(), 1, 'Síndrome de Marfan', 15000.00),
(1026, 112, 4, GETDATE(), 1, 'Leucemia Mieloide', 120000.00),
(1027, 113, 3, GETDATE(), 1, 'Carcinoma Adrenal', 95000.00),
(1028, 114, 7, GETDATE(), 1, 'Encefalitis Viral', 25000.00);
SET IDENTITY_INSERT Diagnosticos OFF;
GO
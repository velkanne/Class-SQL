CREATE DATABASE vel;
USE vel;

CREATE TABLE Depto(
	Id_Depto INT PRIMARY KEY,
	Nombre_Depto NVARCHAR(50) NOT NULL,
);

CREATE TABLE Empleado(
	Id_Empleado INT PRIMARY KEY,
	Nombre_Empleado NVARCHAR(100) NOT NULL,
	Salario_Empleado DECIMAL(10,2),
	Id_Depto INT,
	CONSTRAINT FK_Depto
		FOREiGN KEY (Id_Depto)
		REFERENCES Depto (Id_Depto)
);


INSERT INTO Depto (Id_Depto, Nombre_Depto) VALUES (1, 'VENTAS');
INSERT INTO Depto (Id_Depto, Nombre_Depto) VALUES (2, 'MARKETING');
INSERT INTO Depto (Id_Depto, Nombre_Depto) VALUES (3, 'TECNOLOGIA');

INSERT INTO Empleado (Id_Empleado, Nombre_Empleado, Salario_Empleado, Id_Depto) VALUES (104, 'CARLOS AURELIO', 500000, 1);
INSERT INTO Empleado (Id_Empleado, Nombre_Empleado, Salario_Empleado, Id_Depto) VALUES (105, 'MARIA ANGELICA', 500000, 2);
INSERT INTO Empleado (Id_Empleado, Nombre_Empleado, Salario_Empleado, Id_Depto) VALUES (106, 'NICOLAS CASTRO', 1500000, 2)
INSERT INTO Empleado (Id_Empleado, Nombre_Empleado, Salario_Empleado, Id_Depto) VALUES (107, 'SEBASTIAN WEKONG', 500000, 1);

SELECT *
FROM Empleado;

SELECT *
FROM Depto;


UPDATE Empleado
SET Salario_Empleado = 1055000
WHERE Id_Empleado = 104;

UPDATE Depto
SET Nombre_Depto = 'I.T.'
WHERE Id_Depto = 3;

DELETE FROM Empleado
WHERE Id_Empleado = 104;
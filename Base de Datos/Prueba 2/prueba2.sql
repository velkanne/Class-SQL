CREATE DATABASE InventarioTechSolutions;

USE InventarioTechSolutions;

CREATE TABLE Proveedores (
    Id_Proveedor INT PRIMARY KEY,
    Nombre_Proveedor VARCHAR(100) NOT NULL,
    Pais VARCHAR(50)
);

CREATE TABLE Productos (
    Id_Producto INT PRIMARY KEY,
    Nombre_Producto VARCHAR(100) NOT NULL,
    Precio DECIMAL(10, 2) NOT NULL,
    Stock INT NOT NULL,
    Id_Proveedor INT,
    FOREIGN KEY (Id_Proveedor) REFERENCES Proveedores(Id_Proveedor)
);

CREATE TABLE Clientes (
    Id_Cliente INT PRIMARY KEY,
    Nombre_Cliente VARCHAR(100) NOT NULL,
    Email VARCHAR(100) UNIQUE
);

CREATE TABLE Ventas (
    Id_Venta INT PRIMARY KEY,
    Fecha_Venta DATE NOT NULL,
    Total DECIMAL(10, 2),
    Id_Cliente INT,
    FOREIGN KEY (Id_Cliente) REFERENCES Clientes(Id_Cliente)
);

CREATE TABLE DetalleVenta (
    Id_Venta INT,
    Id_Producto INT,
    Cantidad INT NOT NULL,
    Precio_Unitario DECIMAL(10, 2) NOT NULL,
    PRIMARY KEY (Id_Venta, Id_Producto),
    FOREIGN KEY (Id_Venta) REFERENCES Ventas(Id_Venta),
    FOREIGN KEY (Id_Producto) REFERENCES Productos(Id_Producto)
);

INSERT INTO Proveedores (Id_Proveedor, Nombre_Proveedor, Pais) VALUES
(1, 'Nigga-link Inc.', 'USA'),
(2, 'Negro-Tech I.L.', 'España'),
(3, 'Free Tibet Industries.', 'China');

INSERT INTO Productos (Id_Producto, Nombre_Producto, Precio, Stock, Id_Proveedor) VALUES
(1, 'Laptop Gamer XG-1', 1200.00, 15, 1),
(2, 'Monitor Curvo 27"', 350.50, 30, 1),
(3, 'Teclado Mecánico RGB', 150.00, 50, 2),
(4, 'Mouse Inalámbrico Pro', 80.75, 100, 2),
(5, 'Webcam HD 1080p', 60.00, 80, 3),
(6, 'Disco Duro SSD 1TB', 110.00, 40, 3),
(7, 'Memoria RAM 16GB DDR4', 95.00, 60, 2),
(8, 'Tarjeta Gráfica RTX 4060', 600.00, 10, 1),
(9, 'Fuente de Poder 750W', 130.00, 25, 2),
(10, 'Gabinete ATX Mid-Tower', 90.00, 4, 3);

UPDATE Productos
SET Precio = Precio * 1.10
WHERE Nombre_Producto = 'Laptop Gamer XG-1';

UPDATE Productos
SET Precio = Precio * 1.10
WHERE Nombre_Producto = 'Tarjeta Gráfica RTX 4060';

DELETE FROM Productos
WHERE Stock < 5;

SELECT * FROM Productos;

SELECT Nombre_Producto, Precio
FROM Productos
WHERE Precio > 500;

SELECT pr.Nombre_Producto, p.Nombre_Proveedor
FROM Productos pr
JOIN Proveedores p ON pr.Id_Proveedor = p.Id_Proveedor;

INSERT INTO Clientes (Id_Cliente, Nombre_Cliente, Email) VALUES
(1, 'Juan Perez', 'juan.perez@email.com'),
(2, 'Ana Gomez', 'ana.gomez@email.com');

INSERT INTO Ventas (Id_Venta, Fecha_Venta, Id_Cliente, Total) VALUES
(1, '2025-09-20', 1, 150.00),
(2, '2025-09-21', 2, 80.75),
(3, '2025-09-22', 1, 600.00);

SELECT
    v.Id_Venta,
    v.Fecha_Venta,
    c.Nombre_Cliente,
    v.Total
FROM Ventas v
JOIN Clientes c ON v.Id_Cliente = c.Id_Cliente
ORDER BY v.Fecha_Venta;
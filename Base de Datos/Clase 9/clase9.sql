-- *** SECCIÓN 1: CREACIÓN DE LA ESTRUCTURA DE LA BASE DE DATOS (DDL) ***

-- 1. Crear la base de datos si no existe
CREATE DATABASE NiggaWare;
GO

-- 2. Usar la base de datos para ejecutar los siguientes comandos
USE NiggaWare;
GO

-- 3. Crear la tabla de Proveedores, ahora llamada ProveedorChino (Nueva tabla añadida)
CREATE TABLE ProveedorChino (
    Id_Proveedor INT PRIMARY KEY,
    Nombre_Proveedor VARCHAR(100),
    Pais VARCHAR(50)
);

-- 4. Crear la tabla de Productos (relacionada con ProveedorChino)
-- 'FOREIGN KEY (Id_Proveedor)' crea el vínculo con la tabla ProveedorChino.
CREATE TABLE Productos (
    Id_Producto INT PRIMARY KEY,
    Nombre_Producto VARCHAR(100),
    Precio DECIMAL(10,2),
    Stock INT,
    Id_Proveedor INT,
    -- ¡CAMBIO A ProveedorChino!
    FOREIGN KEY (Id_Proveedor) REFERENCES ProveedorChino(Id_Proveedor)
);

-- 5. Crear la tabla de Clientes
CREATE TABLE Clientes (
    Id_Cliente INT PRIMARY KEY,
    Nombre_Cliente VARCHAR(100),
    Email VARCHAR(100)
);

-- 6. Crear la tabla de Ventas (relacionada con Clientes)
CREATE TABLE Ventas (
    Id_Venta INT PRIMARY KEY,
    Fecha_Venta DATE,
    Total DECIMAL(10,2),
    Id_Cliente INT,
    FOREIGN KEY (Id_Cliente) REFERENCES Clientes(Id_Cliente)
);

-- 7. Crear la tabla DetalleVenta (Tabla de Relación N:M)
CREATE TABLE DetalleVenta (
    Id_Venta INT,
    Id_Producto INT,
    Cantidad INT,
    Precio_Unitario DECIMAL(10,2),
    PRIMARY KEY (Id_Venta, Id_Producto),
    FOREIGN KEY (Id_Venta) REFERENCES Ventas(Id_Venta),
    FOREIGN KEY (Id_Producto) REFERENCES Productos(Id_Producto)
);
GO

---
-- SECCIÓN 2: INSERCIÓN DE DATOS (DML) - Adaptada

-- 1. Insertar 3 proveedores en ProveedorChino
-- ¡CAMBIO A ProveedorChino!
INSERT INTO ProveedorChino (Id_Proveedor, Nombre_Proveedor, Pais) VALUES
(1, 'TechGlobal', 'Chile'),
(2, 'ElectroWorld', 'Argentina'),
(3, 'Innovatech', 'Perú');
GO

-- 2. Insertar 10 productos
INSERT INTO Productos (Id_Producto, Nombre_Producto, Precio, Stock, Id_Proveedor) VALUES
(1, 'Laptop Gamer XG-1', 1200.00, 15, 1),
(2, 'Monitor Curvo 27\"', 350.50, 30, 1),
(3, 'Teclado Mecánico RGB', 150.00, 50, 2),
(4, 'Mouse Inalámbrico Pro', 80.75, 100, 2),
(5, 'Webcam HD 1080p', 60.00, 80, 3),
(6, 'Disco Duro SSD 1TB', 110.00, 40, 3),
(7, 'Memoria RAM 16GB', 95.00, 60, 2),
(8, 'Tarjeta Gráfica RTX 4060', 600.00, 10, 1),
(9, 'Fuente de Poder 750W', 130.00, 25, 2),
(10, 'Gabinete ATX Mid-Tower', 90.00, 4, 3);
GO

-- 3. Insertar 3 clientes
INSERT INTO Clientes (Id_Cliente, Nombre_Cliente, Email) VALUES
(1, 'Ana Castro', 'ana.castro@mail.com'),
(2, 'Luis Perez', 'luis.perez@mail.com'),
(3, 'Sofía Gómez', 'sofia.gomez@mail.com');
GO

-- 4. Insertar 3 ventas y sus detalles
INSERT INTO Ventas (Id_Venta, Fecha_Venta, Total, Id_Cliente) VALUES
(1, '2025-09-20', 1650.50, 1),
(2, '2025-09-21', 170.75, 2),
(3, '2025-09-22', 170.00, 3);
GO

INSERT INTO DetalleVenta (Id_Venta, Id_Producto, Cantidad, Precio_Unitario) VALUES
(1, 1, 1, 1200.00),
(1, 2, 1, 350.50),
(1, 3, 1, 100.00),
(2, 4, 1, 80.75),
(2, 5, 1, 60.00),
(3, 5, 1, 60.00),
(3, 7, 1, 95.00),
(3, 8, 1, 110.00);
GO

---
-- SECCIÓN 3: CONSULTA DE PRUEBA (DQL) - Sin cambios

-- Objetivo 1: Encontrar el valor mas grande y mas bajo
-- Pregunta ¿Cuál es el precio más alto y más bajo de los productos disponibles?

SELECT 
    MAX(Precio) AS Precio_Mas_Alto,
    MIN(Precio) AS Precio_Mas_Bajo
FROM Productos;
GO

-- Objetivo 2: calcular promedio y el total de existencias
-- Pregunta: ¿Cuál es el precio promedio de los productos y cuántas unidades hay en total en stock?

SELECT 
    AVG(Precio) AS Precio_Promedio,
    SUM(Stock) AS Total_Unidades_En_Stock
FROM Productos;
GO

-- Objetivo 3: contar el número de registros
-- Pregunta: ¿Cuántos productos diferentes y cuántos proveedores hay en la base de datos?

SELECT 
    (SELECT COUNT(*) FROM ProveedorChino) AS Total_Proveedores,
    COUNT(*) AS Total_Productos
FROM Productos;
GO

--  Funciones de escala(Transformación por fila)

-- Objetivo 5: Funciones de Cadena(Texto)
-- Pregunta: Mostrar el nombre del producto en mayúsculas y minúsculas, y la longitud del nombre del producto.

SELECT 
    Nombre_Producto,
    UPPER(Nombre_Producto) AS Nombre_Mayusculas,
    LOWER(Nombre_Producto) AS Nombre_Minusculas
    ,LEN(Nombre_Producto) AS Longitud_Nombre
FROM Productos;
GO    
--

-- Objetivo 6: Funciones de Fecha y Hora
-- Pregunta: Mostrar la fecha de venta en diferentes formatos y extraer el año, mes y día.

SELECT 
    Fecha_Venta,
    Id_Venta,
    GETDATE() AS Fecha_Actual,
    YEAR(Fecha_Venta) AS Año,
    MONTH(Fecha_Venta) AS Mes,
    DAY(Fecha_Venta) AS Dia
FROM Ventas;
GO

-- OBJETIVO 7: Combinar Fechas y Cadenas
-- Mostrar la direccion de correo electronico del cliente pero solo en Nombre_Minusculas
SELECT 
    Nombre_Cliente,
    Email,
    LOWER(Email) AS Email_Minusculas
FROM Clientes;
GO

-- Subconsultas simples
-- Objetivo 8: Muestra los productos que tienen un precio superior al precio promedio de todos los productos.
-- Pregunta: ¿Qué productos tienen un precio superior al precio promedio de todos los productos?
SELECT 
    Nombre_Producto,
    Precio
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos);
GO

-- Objetivo 9: Comparar con el maximo de un grupo
-- Pregunta: ¿Qué productos tienen un precio igual al precio más alto de todos los productos?

SELECT 
    Nombre_Producto,
    Precio
FROM Productos
WHERE Precio = (SELECT MAX(Precio) FROM Productos);
GO

-- Objetivo 10: Subconsulta en la cláusula FROM
-- Pregunta: ¿Cuál es el precio promedio de los productos y cuáles son los productos que
-- tienen un precio superior a este promedio?

SELECT 
    p.Nombre_Producto,
    p.Precio,
    avg_p.Precio_Promedio
FROM Productos p
JOIN (SELECT AVG(Precio) AS Precio_Promedio FROM Productos) avg_p
ON p.Precio > avg_p.Precio_Promedio;
GO

-- Objetivo 11: Comparar Directamente
-- Muestra el nombre de los productos que tienen el mimso stock que el "teclado mecanico RGB
-- Pregunta: ¿Qué productos tienen el mismo stock que el "Teclado Mecánico RGB"?

SELECT 
    Nombre_Producto,
    Stock
FROM Productos
WHERE Stock = (SELECT Stock FROM Productos WHERE Nombre_Producto = 'Teclado Mecánico RGB');
GO

-- Objetivo 12: Usar IN con subconsulta
-- Pregunta: ¿Qué productos son suministrados por proveedores que están en 'Chile'
SELECT 
    Nombre_Producto,
    Id_Proveedor
FROM Productos
WHERE Id_Proveedor IN (SELECT Id_Proveedor FROM ProveedorChino WHERE Pais = 'Chile');
GO
-- Objetivo 13: Usar EXISTS con subconsulta
-- Pregunta: ¿Existen productos con un precio superior a 1000?
SELECT 
    Nombre_Producto,
    Precio
FROM Productos p
WHERE EXISTS (SELECT 1 FROM Productos WHERE Precio > 1000);
GO

-- Objetivo 13: USAR NOT IN con subconsulta
-- Pregunta: ¿Qué productos no son suministrados por proveedores que están en 'Argentina
SELECT 
    Nombre_Producto,
    Id_Proveedor
FROM Productos
WHERE Id_Proveedor NOT IN (SELECT DISTINCT Id_Proveedor FROM ProveedorChino WHERE Pais = 'Argentina');
GO
-- Objetivo 14: USAR NOT EXISTS con subconsulta
-- Pregunta: ¿Existen productos con un precio inferior a 50?
SELECT 
    Nombre_Producto,
    Precio
FROM Productos p
WHERE NOT EXISTS (SELECT 1 FROM Productos WHERE Precio < 50);
GO

-- Objetivo 15: Aplicacion Logica y Combinada
-- Pregunta: ¿Qué productos tienen un precio superior al precio promedio y son suministrados por proveedores en 'Chile'?
SELECT 
    Nombre_Producto,
    Precio,
    Id_Proveedor
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos)
AND Id_Proveedor IN (SELECT Id_Proveedor FROM ProveedorChino WHERE Pais = 'Chile');
GO

-- Objetivo 16: Subconsulta Anidada
-- Pregunta: ¿Qué productos tienen un precio superior al precio promedio de los productos suministr
-- por proveedores en 'Chile'?
SELECT 
    Nombre_Producto,
    Precio,
    Id_Proveedor
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos WHERE Id_Proveedor IN 
            (SELECT Id_Proveedor FROM ProveedorChino WHERE Pais = 'Chile'));
GO

-- Objetivo 17: Subconsulta Escalar
-- Pregunta: ¿Qué productos tienen un precio superior al precio promedio de todos los productos?
SELECT 
    Nombre_Producto,
    Precio,
    Id_Proveedor
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos);
GO

-- Objetivo 18: Subconsulta con Funciones de Agregación
-- Pregunta: ¿Qué productos tienen un precio superior al precio promedio de los productos suministr
-- por proveedores en 'Argentina'?
SELECT 
    Nombre_Producto,
    Precio,
    Id_Proveedor
FROM Productos
WHERE Precio > (SELECT AVG(Precio) FROM Productos WHERE Id_Proveedor IN 
            (SELECT Id_Proveedor FROM ProveedorChino WHERE Pais = 'Argentina'));
GO


-- La sentencia SELECT permite mostrar los datos de una tabla.
-- Considerando columnas específicas o todas (*).

SELECT department_id, department_name 
FROM departments;

SELECT first_name, last_name, salary 
FROM employees
WHERE salary BETWEEN 5000 AND 8000; 

-- Uso operador IN
SELECT street_address, city, state_province FROM locations
WHERE city IN ('London', 'Tokyo','Sydney');

-- Uso del operador LIKE
SELECT first_name, last_name, salary
FROM employees
WHERE last_name LIKE 'S%'
ORDER BY salary;
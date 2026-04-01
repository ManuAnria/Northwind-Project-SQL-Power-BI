-- NORTHWIND SQL + POWER BI PROJECT
USE northwind;

-- Rellenar columnas vacias en product
UPDATE product
SET 
    -- Si el producto está descontinuado, ponemos 0 stock, si no, un número aleatorio entre 10 y 100
    unitsInStock = CASE WHEN discontinued = 1 THEN 0 ELSE FLOOR(10 + (RAND() * 90)) END,
    -- Pedidos en camino aleatorios (la mayoría en 0)
    unitsOnOrder = CASE WHEN RAND() > 0.8 THEN FLOOR(5 + (RAND() * 20)) ELSE 0 END,
    -- Nivel de reorden fijo para todos
    reorderLevel = 10
WHERE unitsInStock IS NULL; -- Solo afecta a los que están vacíos

UPDATE product
SET quantityPerUnit = '1';

-- 1 EDA
-- ¿Cuántos productos tenemos por cada categoría?
SELECT
	c.categoryName AS Categoria,
    COUNT(p.productId) AS Cantidad_Productos
FROM product p
LEFT JOIN category c ON p.categoryId = c.categoryId
GROUP BY p.categoryId;

-- ¿Qué productos tienen un nivel de unidades en stock por debajo del nivel de reorden?
SELECT
	productName AS Producto,
    unitsInStock as Stock_Actual,
    reorderLevel AS Cantidad_Restock
FROM product
WHERE unitsInStock < reorderLevel AND discontinued = 0;

-- Localización de clientes: ¿En qué países tenemos más clientes registrados?
SELECT
	country AS Pais,
	COUNT(*) AS Cantidad_Clientes
FROM customer
GROUP BY country
ORDER BY COUNT(*) DESC;

-- Ventas por Empleado: ¿Cuánto ha vendido cada empleado en total (en valor monetario)?
SELECT *
FROM orderdetail;

SELECT
	e.lastName AS Apellido,
    e.firstName AS Nombre,
    SUM((o.unitPrice * o.quantity) * (1 - o.discount)) AS Ventas
FROM employee e
LEFT JOIN salesorder s ON e.employeeID = s.employeeId
JOIN orderdetail o ON s.orderId = o.orderId
GROUP BY e.employeeId
ORDER BY Ventas DESC;

-- Ticket Promedio: ¿Cuál es el valor promedio de un pedido (Order)?
SELECT
	AVG((o.unitPrice * o.quantity) * (1 - o.discount)) AS Venta_Promedio
FROM orderdetail o;

-- Productos "Estrella": ¿Cuáles son los 5 productos que más se han vendido en cantidad total?
SELECT
	p.productName AS Producto,
    SUM(o.quantity) AS Cantidad_Vendida
FROM product p
JOIN orderdetail o ON p.productId = o.productId
GROUP BY p.productName
ORDER BY Cantidad_Vendida DESC
LIMIT 5;

-- Clientes Inactivos: ¿Hay clientes que no han realizado ningún pedido en el último año de la base de datos?
SELECT
	c.companyName AS Cliente,
    COALESCE(MAX(s.orderDate), "Sin órdenes") AS Ultima_Orden
FROM customer c
LEFT JOIN salesorder s ON c.custId = s.custId
GROUP BY c.companyName
HAVING MAX(s.orderDate) < "2007-05-06" OR MAX(s.orderDate) IS NULL
ORDER BY Ultima_Orden DESC;


-- Eficiencia de Envío: ¿Cuál es la diferencia promedio de días entre la fecha en que se pidió (OrderDate) y la fecha en que se envió (ShippedDate) por cada transportista (Shipper)?
SELECT
	sh.shipperId AS ID_Shipper,
	sh.companyName AS Shipper,
    ROUND(AVG(DATEDIFF(s.shippedDate, s.orderDate)), 2) AS Dias_Promedio_Demora
FROM shipper sh
JOIN salesorder s ON sh.shipperId = s.shipperid
WHERE s.shippedDate IS NOT NULL
GROUP BY sh.shipperId
ORDER BY Dias_Promedio_Demora DESC;

-- Análisis de Descuentos: ¿Cuál es el porcentaje promedio de descuento que aplicamos por categoría de producto? ¿Afecta esto al volumen de ventas?
SELECT
	c.categoryName AS Categoria,
    ROUND(AVG(o.discount), 6) AS Descuento_Promedio
FROM category c
LEFT JOIN product p ON c.categoryId = p.categoryId
JOIN orderdetail o on p.productId = o.productId
GROUP BY c.categoryName
ORDER BY Descuento_Promedio DESC;

-- Desviacion de precios
SELECT 
	p.productId,
    p.productName AS Prodcuto,
    c.categoryName AS Categoria,
    p.unitPrice AS Precio_Actual,
    od.unitPrice AS Precio_Vendido,
    (p.unitPrice - od.unitPrice) AS Diferencia,
    -- Calculamos el % de desviación
    ROUND(((p.unitPrice - od.unitPrice) / p.unitPrice) * 100, 2) AS Porcentaje_Desviacion
FROM product p
JOIN category c ON p.categoryId = c.categoryId
JOIN orderdetail od ON p.productId = od.productId
WHERE od.unitPrice < p.unitPrice
GROUP BY p.productId
ORDER BY Porcentaje_Desviacion DESC
LIMIT 50;

-- 2 VIEWS para POWER BI

-- Crear VIEW para segmentar clientes por actividad
CREATE VIEW view_segmentacion_clientes AS
SELECT
	c.custId AS ID_Cliente,
	c.companyName AS Cliente,
    c.country AS Pais,
    COALESCE(MAX(s.orderDate), "Sin órdenes") AS Ultima_Orden,
    DATEDIFF("2008-05-06", MAX(s.orderDate)) AS Dias_Inactividad,
    CASE
		WHEN MAX(s.orderDate) IS NULL THEN "Critico (Sin pedidos)"
        WHEN DATEDIFF("2008-05-06", MAX(s.orderDate)) > 120 THEN "Inactivo (+4 meses sin pedidos)"
        WHEN DATEDIFF("2008-05-06", MAX(s.orderDate)) > 60 THEN "En Riesgo (+2 meses sin pedidos)"
        ELSE "Activo"
    END AS Segmento_Fidelidad
FROM customer c
LEFT JOIN salesorder s ON c.custId = s.custId
GROUP BY c.custId, c.companyName, c.country;

-- Crear View Hechos Ventas
CREATE OR REPLACE VIEW view_hechos_ventas AS
SELECT
	od.orderId,
    so.orderDate AS Fecha_Pedido,
    so.shippedDate AS Fecha_Envio,
    c.companyName AS Cliente,
    c.country AS Pais_Cliente,
    so.shipCountry AS Pais_Destino,
    p.productName AS Producto,
    cat.categoryName AS Categoria,
    CONCAT(e.firstname, " ", e.lastname) AS Vendedor,
    s.companyName AS Proveedor,
    sh.companyName AS Shipper,
    od.unitPrice AS Precio_Venta,
    od.quantity AS Cantidad,
    od.discount AS Descuento,
    ROUND((od.unitPrice * od.quantity * (1 - od.discount)), 2) AS Total_Neto    
FROM orderdetail od
JOIN salesorder so ON od.orderId = so.orderId
JOIN customer c ON so.custId = c.custId
JOIN product p ON od.productId = p.productId
JOIN category cat ON p.categoryId = cat.categoryId
JOIN employee e ON so.employeeId = e.employeeId
JOIN supplier s ON p.supplierId = s.supplierId
JOIN shipper sh ON so.shipperid = sh.shipperId;

-- VIEW de desempeño de empleados
CREATE OR REPLACE VIEW view_employee_performance AS
SELECT
	e.employeeId,
    CONCAT(e.firstname, " ", e.lastname) AS Vendedor,
    e.title AS Cargo,
    COUNT(DISTINCT so.orderId) AS Total_Pedidos,
    ROUND(SUM(od.unitPrice * od.quantity * (1 - od.discount)), 2) AS Total_Vendido
FROM employee e
JOIN salesorder so ON e.employeeId = so.employeeId
JOIN orderdetail od ON so.orderId = od.orderId
GROUP BY e.employeeId, Vendedor, e.title;

-- Create VIEW Inventario y Reposicion

CREATE OR REPLACE VIEW view_inventory_status AS
SELECT 
    p.productId,
    p.productName AS Producto,
    cat.categoryName AS Categoria,
    s.companyName AS Proveedor,
    p.unitsInStock AS Stock_Actual,
    p.reorderLevel AS Nivel_Critico,
    CASE 
        WHEN p.discontinued = 1 THEN 'Descontinuado'
        WHEN p.unitsInStock <= p.reorderLevel THEN 'REPONER URGENTE'
        WHEN p.unitsInStock <= p.reorderLevel * 1.5 THEN 'Stock Bajo'
        ELSE 'Stock OK'
    END AS Estado_Inventario,
    ROUND((p.unitsInStock * p.unitPrice), 2) AS Valor_Inventario_Actual
FROM product p
JOIN category cat ON p.categoryId = cat.categoryId
JOIN supplier s ON p.supplierId = s.supplierId;

SELECT *
FROM view_inventory_status;

-- View suppliers

CREATE OR REPLACE VIEW view_suppliers_analysis AS
SELECT 
    s.supplierId,
    s.companyName AS Proveedor,
    s.country AS Pais_Proveedor,
    cat.categoryName AS Categoria_Principal,
    COUNT(p.productId) AS Cantidad_Productos_Suministrados,
    ROUND(AVG(p.unitPrice), 2) AS Precio_Promedio_Suministro
FROM supplier s
JOIN product p ON s.supplierId = p.supplierId
JOIN category cat ON p.categoryId = cat.categoryId
GROUP BY s.supplierId, s.companyName, s.country, cat.categoryName;

CREATE OR REPLACE VIEW view_suppliers_dim AS
SELECT DISTINCT supplierId, companyName AS Proveedor, country AS Pais_Proveedor
FROM supplier;
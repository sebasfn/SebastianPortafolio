use AdventureWorks2019
GO

/*
-- query total sales by product
-- query total revenue by product
-- query about most recent sales 
-- quantity of sales per month
 identify products with highest sales
identify product with most sales.
UnitPrice Precio_Unitario,
*/ 

/* 
1. Resumen básico de ventas por producto.
Nota: Agrupamos solo por ProductID para consolidar ventas 
incluso si el precio unitario cambió en el tiempo.
*/
/*
1. Basic sales summary by product.
Note: We group only by ProductID to consolidate sales, even if the unit price changed over time.
*/


SELECT 
    ProductID AS Producto,
    SUM(OrderQty) AS TotalVendido
FROM Sales.SalesOrderDetail
GROUP BY ProductID;

/* 
2. Top 10 Productos por Ingresos Totales.
Calculamos el ingreso (Precio * Cantidad) sumado para obtener el valor real.
*/
/*
2. Top 10 Products by Total Revenue.
We calculate the total revenue (Price * Quantity) to obtain the actual value.
*/

SELECT TOP 10 
    ProductID, 
    SUM(OrderQty) AS Unidades_Vendidas,
    SUM(UnitPrice * OrderQty) AS Total_Ingresos
FROM Sales.SalesOrderDetail
GROUP BY ProductID
ORDER BY Unidades_Vendidas DESC;

/* 
3. Análisis de Tendencias Mensuales (Enero - Junio 2014)
Uso de CTEs y Window Functions para rankear productos por mes.
*/
/*
3. Monthly Trend Analysis (January - June 2014)
Use of CTEs and Window Functions to rank products by month.
*/

WITH MonthlySales AS (
    SELECT 
        ProductID,
        DATEPART(MONTH, ModifiedDate) AS mes,
        SUM(OrderQty) AS cantidad_total_vendida
    FROM Sales.SalesOrderDetail
    WHERE 
        ModifiedDate >= '2014-01-01' AND ModifiedDate < '2014-07-01'
    GROUP BY ProductID, DATEPART(MONTH, ModifiedDate)
),
RankedSales AS (
    SELECT
        ProductID,
        mes,
        cantidad_total_vendida,
        ROW_NUMBER() OVER (PARTITION BY mes ORDER BY cantidad_total_vendida DESC) AS rank
    FROM MonthlySales
)
SELECT 
    ProductID,
    CASE mes
        WHEN 1 THEN 'Enero'
        WHEN 2 THEN 'Febrero'
        WHEN 3 THEN 'Marzo'
        WHEN 4 THEN 'Abril'
        WHEN 5 THEN 'Mayo'
        WHEN 6 THEN 'Junio'
    END AS nombre_mes,
    cantidad_total_vendida
FROM RankedSales
WHERE rank <= 10
ORDER BY mes, rank;

/*
4. Análisis Regional
Identifica los mercados más rentables (SalesLastYear) para priorizar
estrategias comerciales durante la crisis.
*/
/*
4. Regional Analysis
Identifies the most profitable markets (Sales Last Year) to prioritize commercial strategies during the crisis.
*/
SELECT 
       Name,
       CountryRegionCode, 
       [Group], 
       SUM(SalesLastYear) AS TotalSalesLastYear
FROM Sales.SalesTerritory
GROUP BY Name, CountryRegionCode, [Group]
ORDER BY TotalSalesLastYear DESC;

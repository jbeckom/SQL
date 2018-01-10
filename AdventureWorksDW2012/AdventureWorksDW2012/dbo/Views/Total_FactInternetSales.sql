
CREATE VIEW	dbo.Total_FactInternetSales
WITH SCHEMABINDING
AS
	SELECT	SUM(fis.DiscountAmount)			AS [Total_DiscountAmount]
			,SUM(fis.ProductStandardCost)	AS [Total_ProductStandardCost]
			,SUM(fis.TotalProductCost)		AS [Total_TotalProductCost]
			,SUM(fis.SalesAmount)			AS [Total_SalesAmount]
			,fis.OrderDate
			,fis.CustomerKey
			,fis.CurrencyKey
			,COUNT_BIG(*)					AS [RecordCount]

	FROM	dbo.FactInternetSales	AS fis

	GROUP BY	fis.OrderDate, fis.CustomerKey, fis.CurrencyKey;

GO
CREATE UNIQUE CLUSTERED INDEX [IX_Total_FactInternetSales]
    ON [dbo].[Total_FactInternetSales]([OrderDate] ASC, [CustomerKey] ASC, [CurrencyKey] ASC);



CREATE VIEW dbo.Total_DimTerritoryAndGeography
AS
SELECT	g.City
		,g.StateProvinceCode
		,g.StateProvinceName
		,g.CountryRegionCode
		,g.EnglishCountryRegionName
		,t.SalesTerritoryGroup
		,t.SalesTerritoryRegion
FROM	dbo.DimGeography	AS g
	INNER JOIN	dbo.DimSalesTerritory AS t
		ON	g.SalesTerritoryKey = t.SalesTerritoryKey
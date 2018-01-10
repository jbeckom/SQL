CREATE TABLE [dbo].[DimProduct] (
    [ProductKey]            INT             IDENTITY (1, 1) NOT NULL,
    [ProductAlternateKey]   NVARCHAR (25)   NULL,
    [ProductSubcategoryKey] INT             NULL,
    [WeightUnitMeasureCode] NCHAR (3)       NULL,
    [SizeUnitMeasureCode]   NCHAR (3)       NULL,
    [EnglishProductName]    NVARCHAR (50)   NOT NULL,
    [SpanishProductName]    NVARCHAR (50)   NOT NULL,
    [FrenchProductName]     NVARCHAR (50)   NOT NULL,
    [StandardCost]          MONEY           NULL,
    [FinishedGoodsFlag]     BIT             NOT NULL,
    [Color]                 NVARCHAR (15)   NOT NULL,
    [SafetyStockLevel]      SMALLINT        NULL,
    [ReorderPoint]          SMALLINT        NULL,
    [ListPrice]             MONEY           NULL,
    [Size]                  NVARCHAR (50)   NULL,
    [SizeRange]             NVARCHAR (50)   NULL,
    [Weight]                FLOAT (53)      NULL,
    [DaysToManufacture]     INT             NULL,
    [ProductLine]           NCHAR (2)       NULL,
    [DealerPrice]           MONEY           NULL,
    [Class]                 NCHAR (2)       NULL,
    [Style]                 NCHAR (2)       NULL,
    [ModelName]             NVARCHAR (50)   NULL,
    [LargePhoto]            VARBINARY (MAX) NULL,
    [EnglishDescription]    NVARCHAR (400)  NULL,
    [FrenchDescription]     NVARCHAR (400)  COLLATE French_CI_AS NULL,
    [ChineseDescription]    NVARCHAR (400)  COLLATE Chinese_PRC_CI_AI NULL,
    [ArabicDescription]     NVARCHAR (400)  COLLATE Arabic_CI_AS NULL,
    [HebrewDescription]     NVARCHAR (400)  COLLATE Hebrew_CI_AS NULL,
    [ThaiDescription]       NVARCHAR (400)  COLLATE Thai_CI_AS NULL,
    [GermanDescription]     NVARCHAR (400)  COLLATE Latin1_General_100_CI_AS NULL,
    [JapaneseDescription]   NVARCHAR (400)  COLLATE Japanese_CI_AS NULL,
    [TurkishDescription]    NVARCHAR (400)  COLLATE Turkish_CI_AS NULL,
    [StartDate]             DATETIME        NULL,
    [EndDate]               DATETIME        NULL,
    [Status]                NVARCHAR (7)    NULL,
    CONSTRAINT [PK_DimProduct_ProductKey] PRIMARY KEY CLUSTERED ([ProductKey] ASC),
    CONSTRAINT [FK_DimProduct_DimProductSubcategory] FOREIGN KEY ([ProductSubcategoryKey]) REFERENCES [dbo].[DimProductSubcategory] ([ProductSubcategoryKey]),
    CONSTRAINT [AK_DimProduct_ProductAlternateKey_StartDate] UNIQUE NONCLUSTERED ([ProductAlternateKey] ASC, [StartDate] ASC)
);


GO
CREATE NONCLUSTERED INDEX [IX_DimProduct_ProductSubcategoryKey]
    ON [dbo].[DimProduct]([ProductSubcategoryKey] ASC);


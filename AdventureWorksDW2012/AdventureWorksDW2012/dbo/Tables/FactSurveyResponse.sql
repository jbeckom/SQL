CREATE TABLE [dbo].[FactSurveyResponse] (
    [SurveyResponseKey]             INT           IDENTITY (1, 1) NOT NULL,
    [DateKey]                       INT           NOT NULL,
    [CustomerKey]                   INT           NOT NULL,
    [ProductCategoryKey]            INT           NOT NULL,
    [EnglishProductCategoryName]    NVARCHAR (50) NOT NULL,
    [ProductSubcategoryKey]         INT           NOT NULL,
    [EnglishProductSubcategoryName] NVARCHAR (50) NOT NULL,
    [Date]                          DATETIME      NULL,
    CONSTRAINT [PK_FactSurveyResponse_SurveyResponseKey] PRIMARY KEY CLUSTERED ([SurveyResponseKey] ASC),
    CONSTRAINT [FK_FactSurveyResponse_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [dbo].[DimCustomer] ([CustomerKey]),
    CONSTRAINT [FK_FactSurveyResponse_DateKey] FOREIGN KEY ([DateKey]) REFERENCES [dbo].[DimDate] ([DateKey])
);


GO
CREATE NONCLUSTERED INDEX [IX_FactSurveyResponse_DateKey]
    ON [dbo].[FactSurveyResponse]([DateKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSurveyResponse_CustomerKey]
    ON [dbo].[FactSurveyResponse]([CustomerKey] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_FactSurveyResponse_ProductSubcategoryKey]
    ON [dbo].[FactSurveyResponse]([ProductSubcategoryKey] ASC);


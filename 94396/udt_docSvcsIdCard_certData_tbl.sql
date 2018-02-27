CREATE TYPE	[dbo].[udt_docSvcsIdCard_certData_tbl]	AS TABLE (
	 CertificateNumber		CHAR(13)
	,SequenceNumber			INT
	,EffectiveDate			DATETIME
	,[ExpireDate]			DATETIME
	,PlanEffectiveDate		DATETIME
	,ProductCode			CHAR(5)
	,ProductAppType			CHAR(5)
	,CurrencyCode			VARCHAR(3)
	,SoldDate				DATETIME
	,Deductible				MONEY
	,AgentID				NUMERIC(18,0)
	,CertificateType		VARCHAR(20)
	,InvoiceFrequency		CHAR(1)
	,UNIQUE NONCLUSTERED	(CertificateNumber, SequenceNumber)
);
GO
CREATE TYPE	[dbo].[udt_docSvcsIdCard_insuredData_tbl] AS TABLE (
	 PartyID			INT				NOT NULL
	,CertificateNumber	CHAR(13)		NOT NULL
	,SequenceNumber		INT				NOT NULL
	,ExternalId_Only	VARCHAR(100)
	,InsuredID			NUMERIC(18,0)
	,InsuredType		VARCHAR(20)
	,GroupName			VARCHAR(100)
	,MasterInsuredID	NUMERIC(18,0)
	,[Name]				VARCHAR(100)
	,DateOfBirth		DATETIME
	,EffectiveDate		DATETIME
	,[ExpireDate]		DATETIME
	,IDCardIndicator	TINYINT			--can this be a bit?
	,UNIQUE	NONCLUSTERED (PartyID,CertificateNumber,SequenceNumber)
);
GO
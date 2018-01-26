USE	LCS_SQL;
GO

SELECT	','''+formID+''''
FROM	dbo.ClaimAuthorization
WHERE	Claim_SourceId	= 26
	AND	YRegNum	IS NULL
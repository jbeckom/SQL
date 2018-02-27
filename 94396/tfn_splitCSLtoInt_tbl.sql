CREATE FUNCTION [dbo].[tfn_splitCSLtoInt_tbl]
(
	@list	VARCHAR(MAX)
)
RETURNS  @Result TABLE(val BIGINT)

AS

BEGIN

 

      DECLARE @x XML 

      SELECT @x = CAST('<A>'+ REPLACE(@list,',','</A><A>')+ '</A>' AS XML)

     

      INSERT INTO @Result            

      SELECT t.value('.', 'int') AS inVal

      FROM @x.nodes('/A') AS x(t)


 

    RETURN

END   

GO
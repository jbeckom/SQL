USE [database];
GO

SET ANSI_NULLS ON;
GO

SET QUOTED_IDENTIFIER ON;
GO

CREATE PROCEDURE [schema].[name]
AS
/*******************************************************************************
Description: 

Revision History:
Date			Project			Author				Comments

*******************************************************************************/

SET NOCOUNT ON;

DECLARE	 @errorMessage	VARCHAR(255)	-- local variable to set the error text when raising error
		,@procedure		SYSNAME			-- procedure name
		,@beginTran		TINYINT			-- Transaction indicator ( 0 = No BEGIN TRAN executed :: 1 = BEGIN TRAN executed )
		,@raiserror		TINYINT			-- Raise Error indicator ( 0 = Do NOT call RAISERROR :: 1 = Do call RAISERROR )
		,@rowCount		INT				-- Local variable to store @@ROWCOUNT after INSERT/UPDATE
		,@error			INT				-- Local variable to save @@ERROR

/**********************************/
/***	TRANSACTION MANAGEMENT	***/
/**********************************/
IF @@TRANCOUNT	NOT IN (0,1)
BEGIN 
	SET @beginTran		= 0
	SET @raiserror		= 1
	SET @errorMessage	= 'Invalid @@TRANCOUNT ( ' + CONVERT(char(4), @@TRANCOUNT )+ ' ) in ' + @procedure + '.';

	GOTO Procedure_Exit
END 
     
IF @@TRANCOUNT	= 1
	SET @beginTran = 0
ELSE BEGIN
	BEGIN TRAN
          
	SET @error = @@ERROR
	
	IF (
		@error <> 0
		OR
		@@TRANCOUNT <> 1
	)
	BEGIN
		SET @beginTran			= 0
		SET @raiserror			= 1
		SET @errorMessage		= 'BEGIN TRAN failed in ' + @procedure + '.'

		GOTO Procedure_Exit
	END
	ELSE
		SET @beginTran	= 1
	END

/**********************************/
/***	PROCEDURE PROCESSING	***/
/**********************************/






SET @error	= @@ERROR

IF @error	<> 0
BEGIN
     SET @raiserror		= 1
     SET @errorMessage	= '***CUSTOM ERROR MESSAGE***'

     GOTO Procedure_Exit
END

/******************/
/***	EXIT	***/
/******************/
Procedure_Exit:


--	if TRAN open and no errors, COMMIT
IF (
	@beginTran	= 1
	AND
	@error	= 0
)
BEGIN
	COMMIT TRAN

	SET @error	= @@ERROR

	IF	(
		@error		<> 0
		OR
		@@TRANCOUNT	<> 0
	)
		BEGIN
			SET @raiserror		= 1
			SET @errorMessage	= 'COMMIT TRAN failed in ' + @procedure + '.'
		END
END

--	if TRAN is open and an error ocurred, ROLLBACK
IF	(
	@beginTran	= 1
	AND
	@error		<> 0
)
	ROLLBACK TRAN

-- RAISERROR if necessary
IF @raiserror	<> 0
BEGIN
	RAISERROR	(
		@errorMessage		-- Message text
		,16					-- Severity
		,1					-- State
	)
END

SET NOCOUNT OFF


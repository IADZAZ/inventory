
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-03-07
-- Description:	Verify that standard triggers (by naming convention) exist in this database. 
--				These include table audit triggers and lookup check triggers.
-- =============================================
-- EXEC [adm].[usp_VerifyStandardTriggers];
CREATE PROCEDURE [adm].[usp_VerifyStandardTriggers]

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- Create TableAudit and LookupCheck triggers.
	-- Note:  The called stored procedures delete and then create triggers by naming convention.
	DECLARE	@TableSchema nvarchar(50), @TableName nvarchar(255), @IsLookupTable bit, @Line nvarchar(1000);
	DECLARE TRIGGER_CREATE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName], [IsLookupTable] = (CASE WHEN (LEFT([TableName], 2) = 'lk') THEN 1 ELSE 0 END)
			FROM	[adm].[vDbColumnInfo]
			WHERE	[ColumnId] = 1
			  AND	[TableSchema] != 'adm'
			  AND	LEFT([TableName], 2) != 'jn'
			ORDER BY [TableSchema], [TableName], [ColumnId];
	OPEN TRIGGER_CREATE_CURSOR
	FETCH NEXT FROM TRIGGER_CREATE_CURSOR INTO @TableSchema, @TableName, @IsLookupTable
	WHILE (@@fetch_status <> -1)
	BEGIN

		--PRINT CONCAT('[', @TableSchema, '].[', @TableName, '] (', @IsLookupTable, ')');
		EXEC [adm].[usp_CreateTableAuditTrigger] @TableName, @TableSchema;

		--IF(@IsLookupTable = 1) BEGIN
		--	EXEC [adm].[usp_CreateLookupCheckTrigger] @TableName, @TableSchema;
		--END

		FETCH NEXT FROM TRIGGER_CREATE_CURSOR INTO @TableSchema, @TableName, @IsLookupTable
	END
	CLOSE TRIGGER_CREATE_CURSOR; DEALLOCATE TRIGGER_CREATE_CURSOR

EXIT_HANDLER:
END TRY
BEGIN CATCH
	IF (XACT_STATE()=-1 OR XACT_STATE()=1) ROLLBACK TRANSACTION;
	DECLARE @ErrStr nvarchar(4000);
	EXEC [adm].[usp_HandleError] @@PROCID, @ErrStr OUTPUT;
	THROW;
END CATCH
IF ((XACT_STATE())=1) COMMIT TRANSACTION;
END
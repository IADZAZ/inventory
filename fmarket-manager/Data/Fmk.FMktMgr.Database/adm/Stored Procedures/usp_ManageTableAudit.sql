
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-03-06
-- Description:	Process a table's data change (insert/update/delete) audit.
-- =============================================
CREATE PROCEDURE [adm].[usp_ManageTableAudit]

	@TableName nvarchar(100),
	@AuditJson nvarchar(max)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- Grab counts of Inserted and Deleted.
	DECLARE	@CountDel int = (SELECT COUNT(*) FROM OPENJSON(@AuditJson, '$.Deleted')),
			@CountIns int = (SELECT COUNT(*) FROM OPENJSON(@AuditJson, '$.Inserted'));
	IF (@CountDel + @CountIns = 0) GOTO EXIT_HANDLER;

	-- Pull out Id and LastUpdateBy.
	DECLARE	@UniqueId bigint = (CASE WHEN (@CountIns > 0) THEN (SELECT JSON_VALUE(@AuditJson, '$.Inserted[0].Id')) ELSE (SELECT JSON_VALUE(@AuditJson, '$.Deleted[0].Id')) END),
			@UpdateBy nvarchar(255) = (CASE WHEN (@CountIns > 0) THEN (SELECT JSON_VALUE(@AuditJson, '$.Inserted[0].LastUpdateBy')) ELSE '{unknown}' END);

	-- Set AuditType.
	DECLARE @AuditType char(1) = CASE WHEN (@CountDel<1) THEN 'I' WHEN (@CountIns<1) THEN 'D' ELSE 'U' END, 
			@Count int = CASE WHEN (@CountIns>0) THEN @CountIns ELSE @CountDel END;

	-- Switch AuditType from 'Update' to 'Pseudo-delete' if DateDeactivated was set on Inserted.
	IF (@AuditType = 'U' AND (SELECT JSON_VALUE(@AuditJson, '$.Deleted[0].DateDeactivated')) IS NULL AND (SELECT JSON_VALUE(@AuditJson, '$.Inserted[0].DateDeactivated')) IS NOT NULL) SET @AuditType = 'P';

	-- Create TableAudit record.
	INSERT INTO [adm].[TableAudit]
		([DbUser], [UpdateBy], [AuditType], [TableName], [UniqueId], [RowCount], [AuditJson])
		VALUES
		(SYSTEM_USER, COALESCE(@UpdateBy, '{unknown}'), @AuditType, @TableName, @UniqueId, @Count , @AuditJson);

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
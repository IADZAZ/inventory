
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-03-06
-- Description:	Used to create the TableAudit trigger for the passed in table.
--				An INSERT, UPDATE, DELETE trigger will be created.
-- =============================================
-- [adm].[usp_CreateTableAuditTrigger] 'Address'
CREATE PROCEDURE [adm].[usp_CreateTableAuditTrigger]

	@TableName nvarchar(100),
	@TableSchema nvarchar(20) = 'dbo'

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- Declare Locals.
	DECLARE	@Sql nvarchar(2000);

	-- Drop the Trigger if it already exists.
	SET @Sql = 'IF EXISTS (SELECT * FROM [dbo].[sysobjects] WHERE id = object_id(N''[' + @TableSchema + '].[Trigger_TableAudit_' + @TableSchema + @TableName + ']'') AND OBJECTPROPERTY(id, N''IsTrigger'') = 1) BEGIN
					DROP TRIGGER [' + @TableSchema + '].[Trigger_TableAudit_' + @TableSchema + @TableName + '];
				END';
	EXEC sp_executesql @Sql;


	-- Create "TableAudit" Trigger for current table.
	-- NOTE:  DO NOT reformat the sql string below...
	SET @Sql = 'CREATE TRIGGER [' + @TableSchema + '].[Trigger_TableAudit_' + @TableSchema + @TableName + '] ON [' + @TableSchema + '].[' + @TableName + ']
FOR INSERT, UPDATE, DELETE AS
SET NOCOUNT ON

	DECLARE @TableName sysname = (SELECT CONCAT(''['', OBJECT_SCHEMA_NAME([parent_id]), ''].['', OBJECT_NAME([parent_id]), '']'') FROM [sys].[triggers] WHERE OBJECT_ID = @@PROCID);
	DECLARE @Json nvarchar(max) = (	SELECT [Deleted]=(SELECT * FROM [Deleted] FOR JSON AUTO), [Inserted]=(SELECT * FROM [Inserted] FOR JSON AUTO) FOR JSON PATH, WITHOUT_ARRAY_WRAPPER );
	EXEC [adm].[usp_ManageTableAudit] @TableName, @Json;';
	EXEC sp_ExecuteSql @Sql;

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
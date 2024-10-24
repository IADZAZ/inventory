
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-05-30
-- Description:	Create a lookup table.
-- =============================================
-- EXEC [adm].[usp_CreateTable_Lookup] 'ContextType1';
CREATE PROCEDURE [adm].[usp_CreateTable_Lookup]

	@BaseTableName nvarchar(100),
	@TableSchema nvarchar(20) = 'dbo'

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- Declare variables.
	DECLARE	@Sql nvarchar(4000),
			@FullName nvarchar(100),
			@ErrMsg nvarchar(255);


	-- Initialize variables.
	SET @FullName = 'lk' + @BaseTableName;


	-- "Clean" passed in arguments.
	SET @BaseTableName = LTRIM(RTRIM(@BaseTableName));
	IF(@BaseTableName = '') SET @BaseTableName = NULL;


	-- Validate inputs...
	IF( @BaseTableName IS NULL ) BEGIN
		SET @ErrMsg = 'BaseTableName is required.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	IF(LEFT(@BaseTableName, 2) = 'lk') BEGIN
		SET @ErrMsg = 'Do not prepend ''lk'' to BaseTableName parameter.';
		RAISERROR (@ErrMsg, 16 , -1);
	END


	-- Create the table.
	-- Note:	No DateCreated/DateDeactivated field - lookups (enums/fixed-lists) are considered configuration, 
	--			if created/deleted info is needed, look in DbAudit.
	SET @Sql = 'CREATE TABLE [' + @TableSchema + '].[' + @FullName+ '] (
		[Id]				SMALLINT				IDENTITY (1, 1)	NOT NULL,
		[Code]				NVARCHAR (10)			NOT NULL,
		[Name]				NVARCHAR (50)			NOT NULL,
		[Description]		NVARCHAR (255)			NULL,
		[DateCreated]       DATETIMEOFFSET (7)		CONSTRAINT [DF_' + @TableSchema + @FullName + '_DateCreated] DEFAULT (sysdatetimeoffset())	NOT NULL,
		[LastUpdateBy]      NVARCHAR (50)			CONSTRAINT [DF_' + @TableSchema + @FullName + '_LastUpdateBy] DEFAULT (''{system}'')		NOT NULL,
		[DateDeactivated]   DATETIMEOFFSET (7)		NULL,
		CONSTRAINT [PK_' + @TableSchema + @FullName + '] PRIMARY KEY CLUSTERED ([Id] ASC),
		CONSTRAINT [U_' +  @TableSchema + @FullName+ '_Code] UNIQUE NONCLUSTERED ([Code]),
		CONSTRAINT [U_' +  @TableSchema + @FullName+ '_Name] UNIQUE NONCLUSTERED ([Name])
	) ON [PRIMARY]';
	EXEC sp_ExecuteSql @Sql;


	-- Create its "LookupCheck" Trigger.
	--EXEC [adm].[usp_CreateLookupCheckTrigger] @FullName, @TableSchema;


	-- Create its Audit Trigger.
	--EXEC [adm].[usp_CreateTableAuditTrigger] @FullName, @TableSchema;

END TRY
BEGIN CATCH
	IF (XACT_STATE()=-1 OR XACT_STATE()=1) ROLLBACK TRANSACTION;
	DECLARE @ErrStr nvarchar(4000);
	EXEC [adm].[usp_HandleError] @@PROCID, @ErrStr OUTPUT;
	THROW;
END CATCH
IF ((XACT_STATE())=1) COMMIT TRANSACTION;
END
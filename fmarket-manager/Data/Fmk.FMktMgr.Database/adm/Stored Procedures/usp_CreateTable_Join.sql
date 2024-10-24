
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-01-22
-- Description:	Create a join (junction) table.
-- =============================================
-- EXEC [adm].[usp_CreateTable_Join] 'dbo', 'Company', 'dbo', 'Address', 'dbo';
CREATE PROCEDURE [adm].[usp_CreateTable_Join]

	@ParentTableSchema nvarchar(20),
	@ParentTableName nvarchar(100),
	@ChildTableSchema nvarchar(20),
	@ChildTableName nvarchar(100),
	@NewTableSchema nvarchar(20),
	@NewTableName nvarchar(150) = null

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	SET @ParentTableSchema = REPLACE(REPLACE(LTRIM(RTRIM(@ParentTableSchema)), '[', ''), ']', '')
	SET @ParentTableName = REPLACE(REPLACE(LTRIM(RTRIM(@ParentTableName)), '[', ''), ']', '')
	SET @ChildTableSchema = REPLACE(REPLACE(LTRIM(RTRIM(@ChildTableSchema)), '[', ''), ']', '')
	SET @ChildTableName = REPLACE(REPLACE(LTRIM(RTRIM(@ChildTableName)), '[', ''), ']', '')
	SET @NewTableSchema = REPLACE(REPLACE(LTRIM(RTRIM(@NewTableSchema)), '[', ''), ']', '')
	SET @NewTableName = REPLACE(REPLACE(LTRIM(RTRIM(@NewTableName)), '[', ''), ']', '')

	-- Declare variables.
	DECLARE	@Sql nvarchar(4000),
			@ParentIdDataType nvarchar(8),
			@ChildIdDataType nvarchar(8),
			@ErrMsg nvarchar(255);


	-- Initialize some variables.
	SET @NewTableName = LTRIM(RTRIM(@NewTableName));
	IF(LEN(@NewTableName) < 3) SET @NewTableName = NULL;
	SET @ParentIdDataType = 'INT';
	SET @ChildIdDataType = 'INT';


	-- "Clean" passed in arguments.
	SET @ParentTableName = LTRIM(RTRIM(@ParentTableName));
	IF(@ParentTableName = '') SET @ParentTableName = NULL;
	SET @ChildTableName = LTRIM(RTRIM(@ChildTableName));
	IF(@ChildTableName = '') SET @ChildTableName = NULL;


	-- Validate inputs...
	IF( (@ParentTableName IS NULL) OR (@ChildTableName IS NULL) ) BEGIN
		SET @ErrMsg = 'ParentTableName and ChildTableName are required.';
		RAISERROR (@ErrMsg, 16 , -1);
	END


	-- For Lookup table, need to change data type.
	IF( LEFT(@ParentTableName, 2) = 'lk') BEGIN
		SET @ParentIdDataType = 'SMALLINT';
	END
	IF( LEFT(@ChildTableName, 2) = 'lk') BEGIN
		SET @ChildIdDataType = 'SMALLINT';
	END
	
	
	-- Set NewTableName if one was not passed in.
	IF(@NewTableName IS NULL) BEGIN
		SET @NewTableName = 'jn' + @ParentTableName + @ChildTableName;
	END

	
	-- Validate Parent and Child table values represent existing tables with the expected identity column.
	CREATE TABLE #CheckIdTbl ([Id] int);
	SET @Sql = '	SELECT	TOP 1 COL.[Id]
					FROM	sysobjects TBL
							INNER JOIN sys.schemas SCH
							 ON TBL.uid = SCH.schema_id
							INNER JOIN syscolumns COL
							 ON TBL.[id] = COL.[id]
					WHERE	TBL.[name] = ''' + @ParentTableName + '''
					  AND	COL.[name] = ''Id''
					  AND	SCH.[name] = ''' + @ParentTableSchema + '''
					  AND	COL.status = 128';
	INSERT INTO #CheckIdTbl	EXEC sp_ExecuteSql @Sql;
	IF( (SELECT COUNT([Id]) FROM #CheckIdTbl) != 1) BEGIN
		SET @ErrMsg = 'Unable to create junction table.  The ParentTable ''' + @ParentTableSchema + '.' + @ParentTableName + ''' does not exist, or does not contain expected identity column ''Id''.';
		RAISERROR (@ErrMsg, 16 , -1);
	END


	TRUNCATE TABLE #CheckIdTbl
	SET @Sql = '	SELECT	TOP 1	COL.[id]
					FROM	sysobjects TBL
							INNER JOIN sys.schemas SCH
							 ON TBL.uid = SCH.schema_id
							INNER JOIN syscolumns COL
							 ON TBL.[id] = COL.[id]
					WHERE	TBL.[name] = ''' + @ChildTableName + '''
					  AND	COL.[name] = ''Id''
					  AND	SCH.[name] = ''' + @ChildTableSchema + '''
					  AND	COL.status = 128';
	INSERT INTO #CheckIdTbl EXEC sp_ExecuteSql @Sql;
	IF( (SELECT COUNT([Id]) FROM #CheckIdTbl) != 1) BEGIN
		SET @ErrMsg = 'Unable to create junction table. The ChildTable ''' + @ChildTableSchema + '.' + @ChildTableName + ''' does not exist, or does not contain expected identity column ''Id''.';
		RAISERROR (@ErrMsg, 16 , -1);
	END
	DROP TABLE #CheckIdTbl;

	
	-- Create the table.
	SET @Sql = 'CREATE TABLE [' + @NewTableSchema + '].[' + @NewTableName + '] (
		[Id] INT IDENTITY (1, 1) NOT NULL ,
		[' + @ParentTableName + 'Id] [' + @ParentIdDataType + '] NOT NULL ,
		[' + @ChildTableName + 'Id] [' + @ChildIdDataType + '] NOT NULL,
		[DateCreated] DATETIMEOFFSET (7) CONSTRAINT [DF_' + @NewTableSchema + @NewTableName + '_DateCreated] DEFAULT (sysdatetimeoffset()) NOT NULL,
		[LastUpdateBy] NVARCHAR (50) CONSTRAINT [DF_' + @NewTableSchema + @NewTableName + '_LastUpdateBy] DEFAULT (''{system}'') NOT NULL,
		[DateDeactivated] DATETIMEOFFSET (7) NULL,
		CONSTRAINT [PK_' + @NewTableSchema + @NewTableName + '] PRIMARY KEY CLUSTERED ([' + @ParentTableName + 'Id] ASC, [' + @ChildTableName + 'Id] ASC)
	) ON [PRIMARY]';
	EXEC sp_ExecuteSql @Sql;


	-- Create its Foreign Keys.
	DECLARE	@PointerToParentTable nvarchar(100) = @ParentTableName + 'Id',
			@PointerToChildTable nvarchar(100) = @ChildTableName + 'Id';
	EXEC [adm].[usp_CreateForeignKey] @NewTableSchema, @NewTableName, @PointerToParentTable, @ParentTableSchema, @ParentTableName, 'PAR';
	EXEC [adm].[usp_CreateForeignKey] @NewTableSchema, @NewTableName, @PointerToChildTable, @ChildTableSchema, @ChildTableName, 'PAR';
	

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
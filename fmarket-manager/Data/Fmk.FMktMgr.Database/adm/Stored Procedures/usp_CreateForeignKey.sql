
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-06-21
-- Description:	Create a Foreign Key along with its Non-Clustered Index.
-- =============================================
-- EXEC [adm].[usp_CreateForeignKey] 'dbo', 'DbConnection', 'Col01', 'dbo', 'Context';
CREATE PROCEDURE [adm].[usp_CreateForeignKey]

	@TableSchema nvarchar(20),
	@TableName nvarchar(100),
	@ColumnName nvarchar(100),
	@ForeignTableSchema nvarchar(20),
	@ForeignTableName nvarchar(100),
	@TypeCode nvarchar(20),
	@IsCascadeDelete bit = 1,
	@ForeignColumnName nvarchar(100) = 'Id'

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	IF (@TypeCode NOT IN ('REF','PAR')) BEGIN
		RAISERROR ('Creation of managed foreign keys requires @Typecode (currently "REF" or "PAR").', 16 , -1);
	END

	SET @TableSchema = REPLACE(REPLACE(LTRIM(RTRIM(@TableSchema)), '[', ''), ']', '')
	SET @TableName = REPLACE(REPLACE(LTRIM(RTRIM(@TableName)), '[', ''), ']', '')
	SET @ColumnName = REPLACE(REPLACE(LTRIM(RTRIM(@ColumnName)), '[', ''), ']', '')
	SET @ForeignTableSchema = REPLACE(REPLACE(LTRIM(RTRIM(@ForeignTableSchema)), '[', ''), ']', '')
	SET @ForeignTableName = REPLACE(REPLACE(LTRIM(RTRIM(@ForeignTableName)), '[', ''), ']', '')
	SET @ForeignColumnName = REPLACE(REPLACE(LTRIM(RTRIM(@ForeignColumnName)), '[', ''), ']', '')

	-- Create the Foreign Key
	DECLARE @CascadeDeleteStr nvarchar(20) = CASE (@IsCascadeDelete) WHEN 1 THEN ' ON DELETE CASCADE' ELSE '' END;
	DECLARE	@Sql nvarchar(4000);
	SET @Sql = 'ALTER TABLE [' + @TableSchema + '].[' + @TableName + '] 
				ADD CONSTRAINT [FK_' + @TypeCode + '_' + @TableSchema + @TableName + '_' + @ColumnName + '_' + @ForeignTableSchema + @ForeignTableName +'_' + @ForeignColumnName + '] 
				FOREIGN KEY ([' + @ColumnName +']) REFERENCES [' + @ForeignTableSchema + '].[' + @ForeignTableName +'] ([' + @ForeignColumnName + '])' + @CascadeDeleteStr + ';'
	--PRINT @Sql;
	EXEC sp_ExecuteSql @Sql;

	-- Create the Index to support the ForeignKey.
	SET @Sql = 'CREATE NONCLUSTERED INDEX IX_' + @TableSchema + @TableName + '_' + @ColumnName + ' ON [' + @TableSchema + '].[' + @TableName + ']([' + @ColumnName + '] ASC);'
	--PRINT @Sql;
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

-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-03-07
-- Description:	Verify that standard indexes (by naming convention) exist in this database. 
--				These include join table indexes, pseudo-delete indexes, and foreign key 
--				indexes.
-- =============================================
-- [adm].[usp_VerifyStandardIndexes];
CREATE PROCEDURE [adm].[usp_VerifyStandardIndexes]

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- SELECT * FROM [sys].[indexes] WHERE [name] LIKE '%IX%'
	DECLARE @Sql nvarchar(500), @IndexName nvarchar(255), @IndexCreateName nvarchar(255), @ExistCount int = 0,
			@Sch nvarchar(20), @Tbl nvarchar(100), @Col nvarchar(100);
	
	-- Create an index on all DateDeactivated/DateDeleted/IsDeleted fields.
	-- This is vital since all selects should check this (pseudo-delete).
	DECLARE JNTBL_INDEX_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName], [ColumnName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	(	([FkTableName] IS NOT NULL)
						OR (LEFT([TableName], 2) = 'jn' AND [IsIdentity] = 0 AND [DataType] IN ('int', 'smallint')) --(should have been covered in FK check)
						OR ([ColumnName] IN ('DateDeactivated', 'DateDeleted', 'IsDeleted', 'IsActive', 'IsInactive') )
					)
			 -- AND	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			ORDER BY [TableSchema], [TableName], [ColumnId];
	OPEN JNTBL_INDEX_CURSOR
	FETCH NEXT FROM JNTBL_INDEX_CURSOR INTO @Sch, @Tbl, @Col
	WHILE (@@fetch_status <> -1)
	BEGIN

		--PRINT CONCAT('[', @Sch, '].[', @Tbl, '].[', @Col, ']');
		SET	@IndexName = CONCAT('IX_', @Sch, @Tbl, '_' , @Col)
		SET	@IndexCreateName = CONCAT(@IndexName, ' ON [', @Sch, '].[', @Tbl, ']')
		IF (NOT EXISTS (SELECT [object_id] FROM [sys].[indexes] WHERE [name] = @IndexName)) BEGIN
			PRINT CONCAT('Index missing (will be create):  ''' , @IndexName, '''')
		END ELSE BEGIN
			SET @ExistCount = @ExistCount + 1;
		END

		SET @Sql = CONCAT('DROP INDEX IF EXISTS ', @IndexCreateName, ';');
		EXEC sp_ExecuteSql @Sql;
		
		SET @Sql = CONCAT('CREATE NONCLUSTERED INDEX ', @IndexCreateName, '([', @Col , '] ASC);');
		EXEC sp_ExecuteSql @Sql;

		FETCH NEXT FROM JNTBL_INDEX_CURSOR INTO @Sch, @Tbl, @Col
	END
	CLOSE JNTBL_INDEX_CURSOR; DEALLOCATE JNTBL_INDEX_CURSOR
	PRINT CONCAT('*** ', @ExistCount, ' Indexes previously existed and were recreated. ***')

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
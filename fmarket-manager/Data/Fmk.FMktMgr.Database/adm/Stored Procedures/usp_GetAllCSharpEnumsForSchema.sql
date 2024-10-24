-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-02-14
-- Description:	Used to generate c# code for enums for a given schema.
-- =============================================
-- [adm].[usp_GetAllCSharpEnumsForSchema] 'dbo'
CREATE PROCEDURE [adm].[usp_GetAllCSharpEnumsForSchema]

	@DictatedTableSchema nvarchar(50) = 'dbo'

AS
BEGIN
SET NOCOUNT ON;

	DECLARE	@TableSchema nvarchar(50), @TableName nvarchar(255), @Line nvarchar(1000);
	DECLARE EACHTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[ColumnId] = 1
			  AND	[IsLookupTable] = 1
			  AND	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			ORDER BY [TableSchema], [TableName];
	OPEN EACHTABLE_CURSOR
	FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	WHILE (@@fetch_status <> -1)
	BEGIN
	
		SET @Line = 'EXEC [adm].[usp_GetCSharpEnum] ''' + @TableSchema + ''', ''' + @TableName + ''';';
		--PRINT @Line;
		EXECUTE sp_executesql @Line;
		PRINT '';

		FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	END
	CLOSE EACHTABLE_CURSOR DEALLOCATE EACHTABLE_CURSOR

	-- EXEC [adm].[usp_GetCSharpEnum] 'dbo', 'lkAddressType';

END
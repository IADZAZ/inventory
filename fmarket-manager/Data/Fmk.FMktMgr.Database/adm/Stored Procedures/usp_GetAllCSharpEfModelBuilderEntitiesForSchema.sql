-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-07-01
-- Description:	Used to generate c# code for Entity Framework ModelBuilder entities for a given schema.
-- =============================================
-- [adm].[usp_GetAllCSharpEfModelBuilderEntitiesForSchema] 'dbo'
CREATE PROCEDURE [adm].[usp_GetAllCSharpEfModelBuilderEntitiesForSchema]

	@DictatedTableSchema nvarchar(50) = 'dbo'

AS	
BEGIN
SET NOCOUNT ON;

	DECLARE	@TableSchema nvarchar(50), @TableName nvarchar(255), @Line nvarchar(1000);
	DECLARE EACHTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[ColumnId] = 1 -- Just getting one rec per table.
			  AND	[IsLookupTable] = 0 
			  AND	[IsJoinTable] = 0
			  AND	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			ORDER BY [TableName], [ColumnId];
	OPEN EACHTABLE_CURSOR
	FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	WHILE (@@fetch_status <> -1)
	BEGIN
		
		PRINT	'public virtual DbSet<' + @TableName + '> ' + @TableName + 'Set { get; set; }';

		FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	END
	CLOSE EACHTABLE_CURSOR; DEALLOCATE EACHTABLE_CURSOR

	PRINT ''; PRINT '';

	DECLARE EACHTABLE2_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[ColumnId] = 1 -- Just getting one rec per table.
			  AND	[IsLookupTable] = 0 
			  AND	[IsJoinTable] = 0
			  AND	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			ORDER BY [TableName], [ColumnId];
	OPEN EACHTABLE2_CURSOR
	FETCH NEXT FROM EACHTABLE2_CURSOR INTO @TableSchema, @TableName
	WHILE (@@fetch_status <> -1)
	BEGIN
		
		SET @Line = 'EXEC [adm].[usp_GetCSharpEfModelBuilderEntity] ''' + @TableSchema + ''', ''' + @TableName + ''';';
		--PRINT @Line;
		EXECUTE sp_executesql @Line;
		PRINT '';

		FETCH NEXT FROM EACHTABLE2_CURSOR INTO @TableSchema, @TableName
	END
	CLOSE EACHTABLE2_CURSOR; DEALLOCATE EACHTABLE2_CURSOR

END
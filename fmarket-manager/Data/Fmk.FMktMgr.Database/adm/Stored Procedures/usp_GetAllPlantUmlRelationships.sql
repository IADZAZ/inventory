-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-02-14
-- Description:	Used to generate c# code for models for a given schema.
-- =============================================
-- [adm].[usp_GetAllPlantUmlRelationships] 'dbo'
CREATE PROCEDURE [adm].[usp_GetAllPlantUmlRelationships]

	@DictatedTableSchema nvarchar(50) = 'dbo'

AS
BEGIN
SET NOCOUNT ON;

	PRINT '@startuml';

	DECLARE	@TableSchema nvarchar(50), @TableName nvarchar(255), @Line nvarchar(1000);
	DECLARE EACHTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableSchema], [TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[ColumnId] = 1
			  AND	[IsLookupTable] = 0 
			  AND	[IsJoinTable] = 0
			  AND	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			ORDER BY [TableSchema], [TableName];
	OPEN EACHTABLE_CURSOR
	FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	WHILE (@@fetch_status <> -1)
	BEGIN
	
		SET @Line = '[adm].[usp_GetPlantUmlRelationshipsForEntity] ''' + @TableSchema + ''', ''' + @TableName + ''';';
		--PRINT @Line;
		EXECUTE sp_executesql @Line;
		PRINT '';

		FETCH NEXT FROM EACHTABLE_CURSOR INTO @TableSchema, @TableName
	END
	CLOSE EACHTABLE_CURSOR DEALLOCATE EACHTABLE_CURSOR;

	PRINT '@enduml';

END
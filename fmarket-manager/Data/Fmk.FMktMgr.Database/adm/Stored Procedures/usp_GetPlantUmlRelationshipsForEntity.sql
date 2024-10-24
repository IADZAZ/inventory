-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-06-07
-- Description:	Creates a base model class for a table.
-- =============================================
-- EXEC [adm].[usp_GetPlantUmlRelationships] 'dbo', 'ActivityPlan'
CREATE PROCEDURE [adm].[usp_GetPlantUmlRelationshipsForEntity]

	@TableSchema nvarchar(50),
	@TableName nvarchar(255)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	-- Add all one-to-one connections.
	DECLARE	@EntityFieldName nvarchar(255), @AllowNull bit, @FkTableName nvarchar(255), @FkIsLookup bit, @FkType nvarchar(20);
	DECLARE	@Connections nvarchar(2000) = '', @Enums nvarchar(1000) = '', @NullableStr nvarchar(10);
	DECLARE BASETBL_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[EntityFieldName], [AllowNull], 
					[FkTableName], [FkIsLookup], [FkType]
			FROM	[adm].[vDbColumnInfo] PAR
			WHERE	[TableSchema] = @TableSchema
			  AND	[TableName] = @TableName
			ORDER BY [ColumnId];
	OPEN BASETBL_CURSOR
	FETCH NEXT FROM BASETBL_CURSOR INTO	@EntityFieldName, @AllowNull, @FkTableName, @FkIsLookup, @FkType
	WHILE (@@fetch_status <> -1)
	BEGIN

		SET @NullableStr = CASE WHEN @AllowNull = 1 THEN ',dashed' ELSE '' END;
		IF (@FkTableName IS NOT NULL) BEGIN
			IF (@FkType = 'Parent') BEGIN
				SET @Enums = @Enums;
			END ELSE IF (@FkIsLookup = 1) BEGIN
				SET @Enums = @Enums + '
enum ' + @EntityFieldName + '{}';
				SET @Connections = @Connections + '
' + @TableName + ' -[#orange]- ' + @EntityFieldName;
			END ELSE BEGIN
				IF (@AllowNull = 1) SET @NullableStr = '[' + REPLACE(@NullableStr, ',', '') + ']'
				SET @Connections = @Connections + '
' + @TableName + ' *-' + @NullableStr + '-* ' + @FkTableName;
			END
		END

		FETCH NEXT FROM BASETBL_CURSOR INTO	@EntityFieldName, @AllowNull, @FkTableName, @FkIsLookup, @FkType
	END
	CLOSE BASETBL_CURSOR DEALLOCATE BASETBL_CURSOR;


	-- Add connections for child entity lists using direct reference.
	DECLARE	@DirectChildTable nvarchar(255)
	DECLARE DIRECTREF_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[IsJoinTable] = 0
			  AND	[FkTableName] = @TableName
			  AND	[FkTableColumn] = 'Id'
			  AND	[FkType] = 'Parent'
			  AND	[TableName] != @TableName --prevents key to self which is handled in field logic above
			ORDER BY [TableName], [ColumnId];
	OPEN DIRECTREF_CURSOR
	FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable
	WHILE (@@fetch_status <> -1)
	BEGIN

				SET @Connections = @Connections + '
' + @TableName + ' *--{ ' + @DirectChildTable;

		FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable
	END
	CLOSE DIRECTREF_CURSOR DEALLOCATE DIRECTREF_CURSOR;


	-- Add connections for child entity lists using jn tables.
	DECLARE @ChildTableSchema nvarchar(50), @JnChildEntityFieldName nvarchar(255), @JnChildEntityIsLookup bit
	DECLARE	@JnFieldName nvarchar(255);
	DECLARE JOINTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ChildTableSchema]=[FkTableSchema], [JnChildEntityFieldName]=[EntityFieldName], [JnChildEntityIsLookup]=[FkIsLookup]
			FROM	[adm].[vDbColumnInfo] PAR
					INNER JOIN (	SELECT	[CTableSchema]=[TableSchema], [CTableName]=[TableName]
									FROM	[adm].[vDbColumnInfo]
									WHERE	[IsJoinTable] = 1
									  AND	[ColumnId] = 2
									  AND	[FkTableName] = @TableName) CHD ON PAR.[TableSchema] = CHD.[CTableSchema] AND PAR.[TableName] = CHD.[CTableName]
			WHERE	[ColumnId] = 3
			ORDER BY [FkTableSchema], [FkTableName];
	OPEN JOINTABLE_CURSOR
	FETCH NEXT FROM JOINTABLE_CURSOR INTO @ChildTableSchema, @JnChildEntityFieldName, @JnChildEntityIsLookup
	WHILE (@@fetch_status <> -1)
	BEGIN

		SET @Connections = CONCAT(@Connections, '
', @TableName, ' ', (CASE WHEN @JnChildEntityIsLookup = 1 THEN '' ELSE '*' END), '-', (CASE WHEN @JnChildEntityIsLookup = 1 THEN '[#orange]' ELSE '' END), '-{ ', @JnChildEntityFieldName, ' : ^');

		IF (@JnChildEntityIsLookup = 1) BEGIN
			SET @Enums = @Enums + '
enum ' + @JnChildEntityFieldName + '{}';
		END

		FETCH NEXT FROM JOINTABLE_CURSOR INTO @ChildTableSchema, @JnChildEntityFieldName, @JnChildEntityIsLookup
	END
	CLOSE JOINTABLE_CURSOR DEALLOCATE JOINTABLE_CURSOR;

	IF (LEN(@Enums) > 0) PRINT @Enums;
	IF (LEN(@Connections) > 0) PRINT @Connections;

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
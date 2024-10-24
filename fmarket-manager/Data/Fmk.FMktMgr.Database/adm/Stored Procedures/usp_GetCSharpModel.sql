-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-06-06
-- Description:	Creates a base model class for a table.
-- =============================================
-- EXEC [adm].[usp_GetCSharpModel] 'dbo', 'ActivityPlan';
-- EXEC [adm].[usp_GetCSharpModel] 'dbo', 'EquipmentModel';
-- EXEC [adm].[usp_GetCSharpModel] 'dbo', 'ContactItem';
CREATE PROCEDURE [adm].[usp_GetCSharpModel]

	@TableSchema nvarchar(50),
	@TableName nvarchar(255)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	DECLARE @BaseClass nvarchar(50) =	
		CASE
			WHEN EXISTS ((SELECT [ColumnName] FROM [adm].[vDbColumnInfo] WHERE [TableSchema] = @TableSchema AND [TableName] = @TableName AND [ColumnName] = 'FlexData')) THEN 'FlexDataEntityBase'
			WHEN EXISTS ((SELECT [ColumnName] FROM [adm].[vDbColumnInfo] WHERE [TableSchema] = @TableSchema AND [TableName] = @TableName AND [ColumnName] = 'DateDeactivated')) THEN 'TerminatableDataEntityBase'
			ELSE 'DataEntityBase'
		END
	PRINT	'';
	PRINT	'public class ' + @TableName + ' : ' + @BaseClass;
	PRINT	'{';

	-- Add all columns.
	DECLARE	@ColumnName nvarchar(255), @DataType nvarchar(255), @EntityDataType nvarchar(255), @EntityFieldName nvarchar(255), @TextMaxLength int, 
			@IsNullable bit, @FkTableName nvarchar(255), @FkIsLookup bit, @FkType nvarchar(20);
	DECLARE	@Line nvarchar(1000), @ListsExist bit = 0;
	DECLARE BASETBL_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ColumnName], [DataType], [EntityDataType], [EntityFieldName], [TextMaxLength], [AllowNull], [FkTableName], [FkIsLookup], [FkType]
			FROM	[adm].[vDbColumnInfo] PAR
			WHERE	[TableSchema] = @TableSchema
			  AND	[TableName] = @TableName
			ORDER BY [ColumnId];
	OPEN BASETBL_CURSOR
	FETCH NEXT FROM BASETBL_CURSOR INTO @ColumnName, @DataType, @EntityDataType, @EntityFieldName, @TextMaxLength, @IsNullable, @FkTableName, @FkIsLookup, @FkType
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@ColumnName NOT IN ('Id', 'DateCreated', 'LastUpdateBy', 'DateDeactivated', 'FlexData')) BEGIN

			SET @Line = CONCAT('	public ', @EntityDataType, (CASE WHEN @IsNullable = 1 THEN '?' ELSE '' END), ' ', @ColumnName, ' { get; set; }');

			IF (@FkTableName IS NOT NULL) BEGIN
				SET @EntityDataType = @FkTableName;
				IF (LEFT(@EntityDataType, 2) = 'lk' COLLATE Latin1_General_CS_AS) SET @EntityDataType = SUBSTRING(@EntityDataType, 3, 9999);
				SET @Line = @Line + CONCAT(char(13), '	' + '//public ', @EntityDataType, (CASE WHEN @IsNullable = 1 THEN '?' ELSE '' END), ' ', @EntityFieldName, ' { get; set; }');
			END

			IF (@EntityDataType = 'string') BEGIN
				SET @Line = @Line + CONCAT(' //(', REPLACE(CAST(@TextMaxLength as nvarchar(10)), '-1', 'max'), ')');
			END

			--IF (@ColumnName != @EntityFieldName) SET @Line = @Line + ' //[' + @ColumnName + ']';

			PRINT @Line;
		END

		FETCH NEXT FROM BASETBL_CURSOR INTO @ColumnName, @DataType, @EntityDataType, @EntityFieldName, @TextMaxLength, @IsNullable, @FkTableName, @FkIsLookup, @FkType
	END
	CLOSE BASETBL_CURSOR DEALLOCATE BASETBL_CURSOR;


	-- Add child entity lists using direct reference.
	DECLARE	@DirectChildTable nvarchar(255), @DirectChildColumn nvarchar(255), @DirectChildField nvarchar(255);
	DECLARE DIRECTREF_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableName], [ColumnName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[IsJoinTable] = 0
			  AND	[FkTableName] = @TableName
			  AND	[FkTableColumn] = 'Id'
			  AND	[FkType] = 'Parent';
	OPEN DIRECTREF_CURSOR
	FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@ListsExist = 0) BEGIN PRINT ''; SET @ListsExist = 1; END

		SET @DirectChildField = @DirectChildTable + 'List';

		PRINT '	public IList<' + @DirectChildTable + '> ' + @DirectChildField + ' { get; set; } = new List<' + @DirectChildTable + '>(); // Relationship via "' + @DirectChildColumn + '" field on ' + @DirectChildTable

		FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn
	END
	CLOSE DIRECTREF_CURSOR DEALLOCATE DIRECTREF_CURSOR;


	-- Add child entity lists using jn tables.
	DECLARE	@ChildTableSchema nvarchar(50), @ChildTableName nvarchar(255), @JnTableName nvarchar(255), @JnChildEntityFieldName nvarchar(255);
	DECLARE	@JnFieldName nvarchar(255);
	DECLARE CHILDOBJECT_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ChildTableSchema]=[FkTableSchema], [ChildTableName]=[FkTableName], [JnTableName]=[TableName], [JnChildEntityFieldName]=[EntityFieldName]
			FROM	[adm].[vDbColumnInfo] PAR
					INNER JOIN (	SELECT	[CTableSchema]=[TableSchema], [CTableName]=[TableName]
									FROM	[adm].[vDbColumnInfo]
									WHERE	[IsJoinTable] = 1
									  AND	[ColumnId] = 2
									  AND	[FkTableName] = @TableName) CHD ON PAR.[TableSchema] = CHD.[CTableSchema] AND PAR.[TableName] = CHD.[CTableName]
			WHERE	[ColumnId] = 3
			ORDER BY [FkTableSchema], [FkTableName];
	OPEN CHILDOBJECT_CURSOR
	FETCH NEXT FROM CHILDOBJECT_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName, @JnChildEntityFieldName
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@ListsExist = 0) BEGIN PRINT ''; SET @ListsExist = 1; END

		SET @JnFieldName = @JnTableName + 'List';
		IF (LEFT(@JnFieldName, 2) = 'jn' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);
		IF (LEFT(@JnFieldName, LEN(@TableName)) = @TableName) SET @JnFieldName = SUBSTRING(@JnFieldName, LEN(@TableName)+1, 9999);
		IF (LEFT(@JnFieldName, 2) = 'lk' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);

		PRINT '	public IList<' + @JnChildEntityFieldName + '> ' + @JnFieldName + ' { get; set; } = [];	// Relationship via ' + @JnTableName;

		FETCH NEXT FROM CHILDOBJECT_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName, @JnChildEntityFieldName
	END
	CLOSE CHILDOBJECT_CURSOR DEALLOCATE CHILDOBJECT_CURSOR;

	PRINT	'}';

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
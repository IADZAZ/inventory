-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-05-31
-- Description:	Creates a base model class for a table.
-- =============================================
-- EXEC [adm].[usp_GetPlantUml] 'dbo', 'Equipment'
-- EXEC [adm].[usp_GetPlantUml] 'dbo', 'EquipmentModel'
-- EXEC [adm].[usp_GetPlantUml] 'dbo', 'ActivityPlan', 0
-- EXEC [adm].[usp_GetPlantUml] 'dbo', 'Company';
CREATE PROCEDURE [adm].[usp_GetPlantUml]

	@TableSchema nvarchar(50),
	@TableName nvarchar(255),
	@IncludeParentConnection bit = 1

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	PRINT	'';
	PRINT	'class ' + @TableName;
	PRINT	'{';

	-- Add all columns.
	DECLARE	@ColumnName nvarchar(255), @EntityDataType nvarchar(255), @EntityFieldName nvarchar(255), @TextMaxLength int, @IsNullable bit, 
			@IsIdentity bit, @IsManaged bit, @FkTableSchema nvarchar(255), @FkTableName nvarchar(255), @FkIsLookup bit, @FkType nvarchar(20);
	DECLARE	@Line nvarchar(1000), @Connections nvarchar(2000) = '', @Enums nvarchar(1000) = '', @Designator char(1), @DataTypeDesc nvarchar(255), 
			@NullableStr nvarchar(10), @ListsExist bit = 0;
	DECLARE BASETBL_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ColumnName], [EntityDataType], [EntityFieldName], [TextMaxLength], [AllowNull], 
					[IsIdentity], [IsManaged], [FkTableSchema], [FkTableName], [FkIsLookup], [FkType]
			FROM	[adm].[vDbColumnInfo] PAR
			WHERE	[TableSchema] = @TableSchema
			  AND	[TableName] = @TableName
			ORDER BY [ColumnId];
	OPEN BASETBL_CURSOR
	FETCH NEXT FROM BASETBL_CURSOR INTO	@ColumnName, @EntityDataType, @EntityFieldName, @TextMaxLength, @IsNullable, 
										@IsIdentity, @IsManaged, @FkTableSchema, @FkTableName, @FkIsLookup, @FkType
	WHILE (@@fetch_status <> -1)
	BEGIN

		SET @Line = '';

		SET @Designator = (	CASE	WHEN @IsIdentity = 1 THEN '~'
									WHEN @IsManaged = 1 THEN '-'
									WHEN @FkTableName IS NOT NULL THEN '#'
									ELSE '+' 
							END);

		SET @DataTypeDesc =	CASE
								WHEN (@EntityDataType = 'string') THEN CONCAT(@EntityDataType, '(', CAST(@TextMaxLength as nvarchar(10)), ')')
								WHEN (@FkTableName IS NOT NULL AND @FkIsLookup = 0) THEN CONCAT('{', @EntityFieldName, '}')
								WHEN (@FkTableName IS NOT NULL AND @FkIsLookup = 1) THEN CONCAT('[', @EntityFieldName, ']')
								ELSE @EntityDataType
							END;
		SET @DataTypeDesc = REPLACE(@DataTypeDesc, '(-1)', '');
		
		IF (@FkTableName IS NULL OR (@FkTableName IS NOT NULL AND @FkType = 'Reference')) BEGIN
			SET @Line = CONCAT(@Line, '	{field}', @Designator, ' ', @EntityFieldName, ' : ', @DataTypeDesc, (CASE WHEN @IsNullable = 1 THEN '?' ELSE '' END));
			PRINT @Line;
		END

		-- Append to Connections.
		SET @NullableStr = CASE WHEN @IsNullable = 1 THEN ',dashed' ELSE '' END;
		IF (@FkTableName IS NOT NULL) BEGIN
			IF (@FkType = 'Parent') BEGIN
				IF (@IncludeParentConnection = 1) BEGIN
				SET @Connections = @Connections + '
' + @TableName + ' }-[#green,thickness=2' + @NullableStr + ']-o ' + @FkTableName;
				END
			END ELSE IF (@FkIsLookup = 1) BEGIN
				SET @Enums = @Enums + '
enum ' + @EntityFieldName + '{}';
				SET @Connections = @Connections + '
' + @TableName + ' -[#orange]- ' + @EntityFieldName;
			END ELSE BEGIN
				IF (@IsNullable = 1) SET @NullableStr = '[' + REPLACE(@NullableStr, ',', '') + ']'
				SET @Connections = @Connections + '
' + @TableName + ' *-' + @NullableStr + '-* ' + @FkTableName;
			END
		END

		FETCH NEXT FROM BASETBL_CURSOR INTO	@ColumnName, @EntityDataType, @EntityFieldName, @TextMaxLength, @IsNullable, 
											@IsIdentity, @IsManaged, @FkTableSchema, @FkTableName, @FkIsLookup, @FkType
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
			  AND	[FkType] = 'Parent'
			ORDER BY [TableName], [ColumnId];
	OPEN DIRECTREF_CURSOR
	FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@ListsExist = 0) BEGIN PRINT '	=='; SET @ListsExist = 1; END

		SET @DirectChildField = @DirectChildTable + 's';
		IF (RIGHT(@DirectChildField, 2) = 'ys') SET @DirectChildField = REVERSE(SUBSTRING(REVERSE(@DirectChildField), 3, 9999)) + 'ies';
		IF (RIGHT(@DirectChildField, 2) = 'ss') SET @DirectChildField = REVERSE(SUBSTRING(REVERSE(@DirectChildField), 3, 9999)) + 'sList';
		PRINT '	#' + @DirectChildField + ': List{' + @DirectChildTable + '}'; -- + ' [via ' + @DirectChildColumn + ' on ' + @DirectChildTable + ']';
				SET @Connections = @Connections + '
' + @TableName + ' *--{ ' + @DirectChildTable;

		FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn
	END
	CLOSE DIRECTREF_CURSOR DEALLOCATE DIRECTREF_CURSOR;


	-- Add child entity lists using jn tables.
	DECLARE @ChildTableSchema nvarchar(50), @ChildTableName nvarchar(255), @JnTableName nvarchar(255), @JnChildEntityFieldName nvarchar(255), @JnChildEntityIsLookup bit
	DECLARE	@JnFieldName nvarchar(255);
	DECLARE JOINTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ChildTableSchema]=[FkTableSchema], [ChildTableName]=[FkTableName], [JnTableName]=[TableName], [JnChildEntityFieldName]=[EntityFieldName], [JnChildEntityIsLookup]=[FkIsLookup]
			FROM	[adm].[vDbColumnInfo] PAR
					INNER JOIN (	SELECT	[CTableSchema]=[TableSchema], [CTableName]=[TableName]
									FROM	[adm].[vDbColumnInfo]
									WHERE	[IsJoinTable] = 1
									  AND	[ColumnId] = 2
									  AND	[FkTableName] = @TableName) CHD ON PAR.[TableSchema] = CHD.[CTableSchema] AND PAR.[TableName] = CHD.[CTableName]
			WHERE	[ColumnId] = 3
			ORDER BY [FkTableSchema], [FkTableName];
	OPEN JOINTABLE_CURSOR
	FETCH NEXT FROM JOINTABLE_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName, @JnChildEntityFieldName, @JnChildEntityIsLookup
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@ListsExist = 0) BEGIN PRINT '	=='; SET @ListsExist = 1; END

		SET @JnFieldName = @JnTableName + 's';
		IF (LEFT(@JnFieldName, 2) = 'jn' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);
		IF (LEFT(@JnFieldName, LEN(@TableName)) = @TableName) SET @JnFieldName = SUBSTRING(@JnFieldName, LEN(@TableName)+1, 9999);
		IF (LEFT(@JnFieldName, 2) = 'lk' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);
		IF (RIGHT(@JnFieldName, 2) = 'ys') SET @JnFieldName = REVERSE(SUBSTRING(REVERSE(@JnFieldName), 3, 9999)) + 'ies';
		IF (RIGHT(@JnFieldName, 2) = 'ss') SET @JnFieldName = REVERSE(SUBSTRING(REVERSE(@JnFieldName), 3, 9999)) + 'sList';
		PRINT '	#' + @JnFieldName + ' List{' + @JnChildEntityFieldName + '}'; -- + ' [via jn]';

		SET @Connections = CONCAT(@Connections, '
', @TableName, ' ', (CASE WHEN @JnChildEntityIsLookup = 1 THEN '' ELSE '*' END), '-', (CASE WHEN @JnChildEntityIsLookup = 1 THEN '[#orange]' ELSE '' END), '-{ ', @JnChildEntityFieldName, ' : ^');

		IF (@JnChildEntityIsLookup = 1) BEGIN
			SET @Enums = @Enums + '
enum ' + @JnChildEntityFieldName + '{}';
		END

		FETCH NEXT FROM JOINTABLE_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName, @JnChildEntityFieldName, @JnChildEntityIsLookup
	END
	CLOSE JOINTABLE_CURSOR DEALLOCATE JOINTABLE_CURSOR;

	PRINT '}';
	IF (LEN(@Enums) > 0) PRINT @Enums;
	IF (LEN(@Connections) > 0) PRINT @Connections;
	print ''

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
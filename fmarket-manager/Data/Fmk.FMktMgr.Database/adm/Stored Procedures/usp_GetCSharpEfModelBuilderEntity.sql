-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-06-21
-- Description:	Creates an EntityFramework ModelBuilder Entity for a table.
-- =============================================
-- EXEC [adm].[usp_GetCSharpEfModelBuilderEntity] 'dbo', 'EquipmentModel';
CREATE PROCEDURE [adm].[usp_GetCSharpEfModelBuilderEntity]

	@TableSchema nvarchar(50),
	@TableName nvarchar(255)

AS
BEGIN
SET NOCOUNT ON;
BEGIN TRANSACTION;
BEGIN TRY

	DECLARE @Schema nvarchar(50) = (SELECT schema_name([schema_id]) FROM sys.objects WHERE schema_name([schema_id]) = @TableSchema AND [name] = @TableName)
	
	DECLARE	@IndexName nvarchar(255) = (SELECT [IndexName] FROM [adm].[vDbIndexInfo] where [TableName] = @TableName AND [IsPrimaryKey] = 1);
	DECLARE	@IndexColumnName nvarchar(255) = REPLACE(REPLACE((SELECT [Columns] FROM [adm].[vDbIndexInfo] where [TableName] = @TableName AND [IsPrimaryKey] = 1), '[', ''), ']', '');

	PRINT	'';
	PRINT	'// public virtual DbSet<' + @TableName + '> ' + @TableName + 'Set { get; set; }';
	PRINT	'modelBuilder.Entity<' + @TableName + '>(entity =>';
	PRINT	'{';
	PRINT	'	entity.HasKey(e => e.' + @IndexColumnName + ').HasName("' + @IndexName + '");';
	PRINT	'	entity.ToTable("' + @TableName + '");';
	PRINT	'	entity.ToTable(e => e.UseSqlOutputClause(false)); //needed since EF code prohibits triggers by default';

	DECLARE	@IsUnique bit, @IsUniqueStr nvarchar(11);
	DECLARE DBINDEX_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[IndexName], [Columns], [IsUnique]
			FROM	[adm].[vDbIndexInfo]
			WHERE	[TableSchema] = @TableSchema
			  AND	[TableName] = @TableName
			  AND	[IsPrimaryKey] = 0;
	OPEN DBINDEX_CURSOR
	FETCH NEXT FROM DBINDEX_CURSOR INTO @IndexName, @IndexColumnName, @IsUnique
	WHILE (@@fetch_status <> -1)
	BEGIN
		
		SET @IndexColumnName = REPLACE(REPLACE(@IndexColumnName, '[', ''), ']', '');
		SET @IsUniqueStr = CASE WHEN @IsUnique = 1 THEN '.IsUnique()' ELSE '' END;	
		PRINT	'	entity.HasIndex(e => e.' + @IndexColumnName + ', "' + @IndexName + '")' + @IsUniqueStr + ';';
		
		FETCH NEXT FROM DBINDEX_CURSOR INTO @IndexName, @IndexColumnName, @IsUnique
	END
	CLOSE DBINDEX_CURSOR DEALLOCATE DBINDEX_CURSOR;


	-- Add all property rules.
	DECLARE	@ColumnName nvarchar(255), @DataType nvarchar(255), @EntityDataType nvarchar(255), @EntityFieldName nvarchar(255), @TextMaxLength int, 
			@AllowNull bit, @DefaultValue nvarchar(1000), @FkTableName nvarchar(255), @FkIsLookup bit, @FkType nvarchar(20);
	DECLARE	@CSharpType nvarchar(255), @CSharpField nvarchar(255), @Line nvarchar(1000), @Extra nvarchar(255), @ListsExist bit = 0,
			@SkipAdd bit;
	DECLARE	@IsRequiredStr nvarchar(13), @TextMaxLengthStr nvarchar(50), @IsUnicodeStr nvarchar(17), @DefaultValueStr nvarchar(1000), @IsFixedLengthStr nvarchar(16);
	DECLARE BASETBL_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ColumnName], [DataType], [EntityDataType], [EntityFieldName], [TextMaxLength], [AllowNull], 
					[DefaultValue], [FkTableName], [FkIsLookup], [FkType]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[TableSchema] = @TableSchema
			  AND	[TableName] = @TableName
			ORDER BY [TableName], [ColumnId]
	OPEN BASETBL_CURSOR
	FETCH NEXT FROM BASETBL_CURSOR INTO @ColumnName, @DataType, @EntityDataType, @EntityFieldName, @TextMaxLength, 
										@AllowNull, @DefaultValue, @FkTableName, @FkIsLookup, @FkType
	WHILE (@@fetch_status <> -1)
	BEGIN
		
		IF (@FkTableName IS NULL) BEGIN --skip foreign key fields
			SET @IsRequiredStr = CASE @AllowNull WHEN 1 THEN '' ELSE '.IsRequired()' END;
			SET @TextMaxLengthStr = CASE @TextMaxLength WHEN NULL THEN '' ELSE '.HasMaxLength(' + CAST(@TextMaxLength as nvarchar(20)) + ')' END;
			SET @IsUnicodeStr = CASE WHEN ((@DataType LIKE '%char%' OR @DataType LIKE '%text%') AND LEFT(@DataType, 1)!='n') THEN '.IsUnicode(false)' ELSE '' END;
			SET @DefaultValueStr = CASE @DefaultValue WHEN NULL THEN '' ELSE '.HasDefaultValueSql("' + @DefaultValue + '")' END;
			SET @IsFixedLengthStr = CASE WHEN (@DataType LIKE '%char%' AND @DataType NOT LIKE '%var%' AND LEFT(@DataType, 1)='n') THEN '.IsFixedLength()' ELSE '' END;
			PRINT CONCAT('	entity.Property(e => e.', @EntityFieldName, ')', @IsRequiredStr, @TextMaxLengthStr, @IsUnicodeStr, @DefaultValueStr, @IsFixedLengthStr, ';');
		END

		FETCH NEXT FROM BASETBL_CURSOR INTO @ColumnName, @DataType, @EntityDataType, @EntityFieldName, @TextMaxLength, 
											@AllowNull, @DefaultValue, @FkTableName, @FkIsLookup, @FkType
	END
	CLOSE BASETBL_CURSOR DEALLOCATE BASETBL_CURSOR;

	IF (EXISTS (SELECT [ColumnName] FROM [adm].[vDbColumnInfo] WHERE [TableSchema] = @TableSchema AND [TableName] = @TableName AND[ColumnName] = 'DateDeactivated')) BEGIN
		PRINT '	entity.HasQueryFilter(x => x.DateDeactivated == null); //soft-delete';
	END

	PRINT	'});';


	-- Add child entity lists using direct reference.
	DECLARE	@DirectChildTable nvarchar(255), @DirectChildColumn nvarchar(255), @DirectChildEntityFieldName nvarchar(255), @DirectChildFKType nvarchar(50);
	DECLARE	@DirectChildField nvarchar(255);
	DECLARE DIRECTREF_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[TableName], [ColumnName], [EntityFieldName], [FkType]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[IsJoinTable] = 0
			  AND	[FkTableName] = @TableName
			  AND	[FkTableColumn] = 'Id'
	OPEN DIRECTREF_CURSOR
	FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn, @DirectChildEntityFieldName, @DirectChildFKType
	WHILE (@@fetch_status <> -1)
	BEGIN

		PRINT	'modelBuilder.Entity<' + @TableName + '>()';
		IF (@DirectChildFKType = 'Reference') BEGIN
			PRINT	'.HasMany<' + @DirectChildTable + '>() //(reference-to)'; -- no list property on referenced entity
		END ELSE BEGIN
			PRINT	'.HasMany(c => c.' + @DirectChildTable + 'List) //(child-list)';
		END
		PRINT	'.WithOne(p => p.' + @DirectChildEntityFieldName + ')';
		PRINT	'.HasForeignKey("' + @DirectChildColumn + '")';
		PRINT	'.IsRequired();';

		FETCH NEXT FROM DIRECTREF_CURSOR INTO @DirectChildTable, @DirectChildColumn, @DirectChildEntityFieldName, @DirectChildFKType
	END
	CLOSE DIRECTREF_CURSOR DEALLOCATE DIRECTREF_CURSOR;


	-- Add child entity lists using jn tables.
	DECLARE	@ChildTableSchema nvarchar(50), @ChildTableName nvarchar(255), @JnTableName nvarchar(255)
	DECLARE @JnFieldName nvarchar(255), @NeedJnTblName bit, @Corrections nvarchar(1000);
	DECLARE CHILDOBJECT_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[ChildTableSchema]=[FkTableSchema], [ChildTableName]=[FkTableName], [JnTableName]=[TableName]
			FROM	[adm].[vDbColumnInfo] PAR
					INNER JOIN (	SELECT	[CTableSchema]=[TableSchema], [CTableName]=[TableName]
									FROM	[adm].[vDbColumnInfo]
									WHERE	[IsJoinTable] = 1
									  AND	[ColumnId] = 2
									  AND	[FkTableName] = @TableName) CHD ON PAR.[TableSchema] = CHD.[CTableSchema] AND PAR.[TableName] = CHD.[CTableName]
			WHERE	[ColumnId] = 3
			ORDER BY [FkTableSchema], [FkTableName];
	OPEN CHILDOBJECT_CURSOR
	FETCH NEXT FROM CHILDOBJECT_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName
	WHILE (@@fetch_status <> -1)
	BEGIN

		SET @JnFieldName = @JnTableName;
		IF (LEFT(@JnFieldName, 2) = 'jn' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);
		IF (LEFT(@JnFieldName, LEN(@TableName)) = @TableName) SET @JnFieldName = SUBSTRING(@JnFieldName, LEN(@TableName)+1, 9999);
		IF (LEFT(@JnFieldName, 2) = 'lk' COLLATE Latin1_General_CS_AS) SET @JnFieldName = SUBSTRING(@JnFieldName, 3, 9999);

		PRINT	'modelBuilder.Entity<' + @TableName + '>()';
		PRINT	'.HasMany(e => e.' + @JnFieldName + 'List)';
		PRINT	'.WithMany()';
		PRINT	'.UsingEntity("' + @JnTableName + '", j =>';
		PRINT	'	{';
		PRINT	'		j.Property(nameof(' + @TableName + ') + "Id").HasColumnName(nameof(' + @TableName + ') + "Id");';
		PRINT	'		j.Property(nameof(' + @TableName + '.' + @JnFieldName + 'List)+"Id").HasColumnName(nameof(' + @ChildTableName + ') + "Id");';
		PRINT	'	});';

		FETCH NEXT FROM CHILDOBJECT_CURSOR INTO @ChildTableSchema, @ChildTableName, @JnTableName
	END
	CLOSE CHILDOBJECT_CURSOR DEALLOCATE CHILDOBJECT_CURSOR;
	
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
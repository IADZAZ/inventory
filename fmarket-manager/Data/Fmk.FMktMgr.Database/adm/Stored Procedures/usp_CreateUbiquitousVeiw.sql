-- ==========================================================================================
-- Author:		Markus Schippel
-- Create date: 2024-04-04
-- Description:	Used to generate a standard (ubiquitous) table view. For now, this view simply 
--				enhances enum information from its table with the enum's string representations 
--				and returns	only active records.
--				Note: If the view exists, it will be replaced.
-- ==========================================================================================
-- [adm].[usp_CreateUbiquitousVeiw] 'dbo', 'jnProductComment', 'dbo', 'Comment';
-- [adm].[usp_CreateUbiquitousVeiw] null, null, 'dbo', 'Product';
CREATE PROCEDURE [adm].[usp_CreateUbiquitousVeiw]

	@ParentJoinTableSchema nvarchar(255),
	@ParentJoinTableName nvarchar(255),
	@TableSchema nvarchar(50), 
	@TableName nvarchar(255),
	@IsDebug bit = 1
	
AS
BEGIN
SET NOCOUNT ON;

	IF (@ParentJoinTableSchema IS NULL) SET @ParentJoinTableSchema = 'dbo';
	
	DECLARE @HasDateDeactivated bit = 0;

	-- Construct name of ubiquitous view.
	DECLARE	@ViewName nvarchar(500) = CONCAT('[', @TableSchema, '].[v_', @TableName, ']') 
	
	DECLARE @JnColumnSql nvarchar(500)='', @JnFromSql nvarchar(1000)='', @JnJoinSql nvarchar(1000)='';
	IF (@ParentJoinTableName IS NOT NULL) BEGIN

		-- Collect values from join table columns.
		DECLARE @JnTableSchema nvarchar(255), @JnTableName nvarchar(255), @ParentColumnName nvarchar(255), @ChildColumnName nvarchar(255), 
				@JnFkTableSchema nvarchar(255), @JnFkTableName nvarchar(255), @JnFkTableColumn nvarchar(255);
		SELECT	@JnTableSchema=[TableSchema], @JnTableName=[TableName], @ParentColumnName=[ColumnName] 
		FROM	[adm].[vDbColumnInfo] 
		WHERE	[TableSchema] = @ParentJoinTableSchema 
		  AND	[TableName] = @ParentJoinTableName
		  AND	[ColumnId] = 2;
		SELECT	@ChildColumnName=[ColumnName], @JnFkTableSchema=[FkTableSchema], @JnFkTableName=[FkTableName], @JnFkTableColumn=[FkTableColumn] 
		FROM	[adm].[vDbColumnInfo] 
		WHERE	[TableSchema] = @ParentJoinTableSchema 
		  AND	[TableName] = @ParentJoinTableName
		  AND	[ColumnId] = 3;

		-- Create join Sql to inject below.
		SET @JnColumnSql = CONCAT('JN.[', @ParentColumnName, '], 
			');
		SET @JnFromSql = CONCAT('[', @JnTableSchema, '].[', @JnTableName, '] JN 
			INNER JOIN ');
		SET @JnJoinSql = CONCAT('ON JN.[', @ChildColumnName, '] = TBL.[', @JnFkTableColumn, '] ');
		
		-- Change view name if has a parent join table.
		SET @ViewName = CONCAT('[', @ParentJoinTableSchema, '].[v_', @TableName, '_Via', SUBSTRING(@ParentJoinTableName, 3, (LEN(@ParentJoinTableName)-2)-LEN(@TableName)), ']') 
	END

	DECLARE	@ColumnId int, @ColumnName nvarchar(255), @FkTableSchema nvarchar(255), 
			@FkTableName nvarchar(255), @FkTableColumn nvarchar(255),
			@RowCnt int=-1, @ColSql nvarchar(4000)='', @FromSql nvarchar(4000), @LkCount int = 0;
	
	-- Append the Join column first (if there is one).
	SET @ColSql = CONCAT(@ColSql, @JnColumnSql);

	-- Delete view if it exists.
	DECLARE @ViewSql nvarchar(4000) = CONCAT('DROP VIEW IF EXISTS ', @ViewName, ';');
	IF (@IsDebug = 1) PRINT @ViewSql;
	IF (@IsDebug = 0) EXECUTE sp_executesql @ViewSql;

	-- Start the From SQL.
	SET @FromSql = CONCAT('
	FROM	', @JnFromSql, '[', @TableSchema + '].[', @TableName, '] TBL ', @JnJoinSql);

	DECLARE EACHROW_CURSOR CURSOR READ_ONLY
	FOR		SELECT  [ColumnId], [ColumnName], [FkTableSchema], [FkTableName], [FkTableColumn]
			FROM	[adm].[vDbColumnInfo]
			WHERE	[TableSchema] = @TableSchema 
			  AND	[TableName] = @TableName
			ORDER BY [ColumnId];
	OPEN EACHROW_CURSOR
	FETCH NEXT FROM EACHROW_CURSOR INTO @ColumnId, @ColumnName, @FkTableSchema, @FkTableName, @FkTableColumn
	WHILE (@@fetch_status <> -1)
	BEGIN
		--PRINT CONCAT(@ColumnId, ' ', @ColumnName, ' ', @FkTableSchema, ' ', @FkTableName, ' ', @FkTableColumn);

		IF (@ColumnName = 'DateDeactivated') BEGIN
			SET @HasDateDeactivated = 1;
			GOTO ENDLOOP;
		END
		SET @RowCnt = @RowCnt+1;
		SET @ColSql = CONCAT(@ColSql, (CASE WHEN (@RowCnt > 0) THEN ', ' ELSE '' END));
		IF ((@RowCnt > 0) AND (@RowCnt % 5) = 0) SET @ColSql = @ColSql + ' 
			';

		-- Add Column.
		IF (@ColumnName = 'Id') BEGIN
			SET @ColSql = CONCAT(@ColSql, '[', @TableName, @ColumnName,']=TBL.[', @ColumnName, ']');
		END ELSE BEGIN
			SET @ColSql = CONCAT(@ColSql, 'TBL.[', @ColumnName, ']');
		END

		IF (LEFT(@FkTableName, 2) = 'lk') BEGIN
			SET @LkCount=@LkCount+1;
			SET @RowCnt = @RowCnt+1;
			SET @ColSql = CONCAT(@ColSql, ', ');
			IF ((@RowCnt > 0) AND (@RowCnt % 5) = 0) SET @ColSql = @ColSql + ' 
			';
			SET @ColSql = CONCAT(@ColSql, '[', SUBSTRING(@ColumnName, 0, LEN(@ColumnName)-1), 'Code]=LK', + @LkCount, '.[Code]');
			SET @RowCnt = @RowCnt+1;
			SET @ColSql = CONCAT(@ColSql, ', ');
			IF ((@RowCnt > 0) AND (@RowCnt % 5) = 0) SET @ColSql = @ColSql + ' 
			';
			SET @ColSql = CONCAT(@ColSql, '[', SUBSTRING(@ColumnName, 0, LEN(@ColumnName)-1), ']=LK', + @LkCount, '.[Name]');

			SET @FromSql = CONCAT(@FromSql, '
			LEFT OUTER JOIN [', @FkTableSchema, '].[', @FkTableName, '] LK', + @LkCount, ' ON TBL.[', @ColumnName, '] = LK', + @LkCount, '.[', @FkTableColumn, ']');
		END
		
		ENDLOOP:
		FETCH NEXT FROM EACHROW_CURSOR INTO @ColumnId, @ColumnName, @FkTableSchema, @FkTableName, @FkTableColumn
	END
	CLOSE EACHROW_CURSOR; DEALLOCATE EACHROW_CURSOR

	-- Create the view SQL.
	SET @ViewSql = CONCAT('CREATE VIEW ', @ViewName, ' AS 
	SELECT	');
	SET @ViewSql = CONCAT(@ViewSql, @ColSql);
	SET @ViewSql = CONCAT(@ViewSql, @FromSql);
	IF (@HasDateDeactivated = 1) BEGIN
		SET @ViewSql = CONCAT(@ViewSql, '
	WHERE	TBL.[DateDeactivated] IS NULL;');
	END
	IF (@IsDebug = 1) PRINT @ViewSql;
	IF (@IsDebug = 0) BEGIN
		EXECUTE sp_executesql @ViewSql;
		PRINT CONCAT('Created (or replaced) ubiquitous view ''', @ViewName, '''.');
	END

END
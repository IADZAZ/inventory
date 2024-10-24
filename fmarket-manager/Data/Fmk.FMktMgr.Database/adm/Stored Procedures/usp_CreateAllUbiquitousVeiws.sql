-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-04-04
-- Description:	Used to create/replace all the standard (ubiquitous) table views. 
-- =============================================
-- [adm].[usp_CreateAllUbiquitousVeiws] 'dbo';
-- [adm].[usp_CreateAllUbiquitousVeiws] 'dbo', 0;
CREATE PROCEDURE [adm].[usp_CreateAllUbiquitousVeiws]

	@DictatedTableSchema nvarchar(50) = 'dbo',
	@IsDebug bit = 1

AS
BEGIN
SET NOCOUNT ON;

	DECLARE	@JnTableSchema nvarchar(255), @JnTableName nvarchar(255), @FkTableSchema nvarchar(255), @FkTableName nvarchar(255);

	-- Add ubiquitous views for all join tables.
	DECLARE EACHTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT  [TableSchema], [TableName], [FkTableSchema], [FkTableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			  AND	LEFT([TableName], 2) = 'jn'
			  AND	[ColumnId] = 3
			ORDER BY [TableSchema], [TableName]
	OPEN EACHTABLE_CURSOR
	FETCH NEXT FROM EACHTABLE_CURSOR INTO @JnTableSchema, @JnTableName, @FkTableSchema, @FkTableName
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@IsDebug = 1) BEGIN
			PRINT (CONCAT(@JnTableSchema, '; ', @JnTableName, '; ', @FkTableSchema, '; ', @FkTableName));
			EXECUTE [adm].[usp_CreateUbiquitousVeiw] @JnTableSchema, @JnTableName, @FkTableSchema, @FkTableName, 1;
			PRINT '';
		END
		IF (@IsDebug = 0) EXECUTE [adm].[usp_CreateUbiquitousVeiw] @JnTableSchema, @JnTableName, @FkTableSchema, @FkTableName, 0;

		FETCH NEXT FROM EACHTABLE_CURSOR INTO @JnTableSchema, @JnTableName, @FkTableSchema, @FkTableName
	END
	CLOSE EACHTABLE_CURSOR; DEALLOCATE EACHTABLE_CURSOR
	
	-- Add ubiquitous views for all standard tables.
	DECLARE EACHTABLE_CURSOR CURSOR READ_ONLY
	FOR		SELECT	DISTINCT [TableSchema], [TableName]
			FROM	[adm].[vDbColumnInfo]
			WHERE	(@DictatedTableSchema IS NULL OR @DictatedTableSchema = [TableSchema])
			  AND	LEFT([TableName], 2) != 'jn'
			  AND	LEFT([TableName], 2) != 'lk'
			ORDER BY [TableSchema], [TableName]
	OPEN EACHTABLE_CURSOR
	FETCH NEXT FROM EACHTABLE_CURSOR INTO @JnTableSchema, @JnTableName
	WHILE (@@fetch_status <> -1)
	BEGIN

		IF (@IsDebug = 1) BEGIN
			PRINT (CONCAT(@JnTableSchema, '; ', @JnTableName));
			EXECUTE [adm].[usp_CreateUbiquitousVeiw] NULL, NULL, @JnTableSchema, @JnTableName, 1;
			PRINT '';
		END
		IF (@IsDebug = 0) EXECUTE [adm].[usp_CreateUbiquitousVeiw] NULL, NULL, @JnTableSchema, @JnTableName, 0;

		FETCH NEXT FROM EACHTABLE_CURSOR INTO @JnTableSchema, @JnTableName
	END
	CLOSE EACHTABLE_CURSOR; DEALLOCATE EACHTABLE_CURSOR

END
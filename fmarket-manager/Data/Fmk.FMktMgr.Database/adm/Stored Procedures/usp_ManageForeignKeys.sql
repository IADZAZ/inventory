
-- =============================================
-- Author:		Markus Schippel
-- Create date: 2024-01-18
-- Description:	Manages foreign keys for this database by storing ones that need to be kept around
--				in the [adm].[ForeignKeyDefinitions] table.
-- =============================================
-- EXEC [adm].[usp_ManageForeignKeys];																	-- Analyze
-- EXEC [adm].[usp_ManageForeignKeys] @Directive='JustShowFkInfoTable';									-- Analyze by returning table with FK info and sql to do manual tweaking
------------------------------------------------
-- --EXEC [adm].[usp_ManageForeignKeys] @RemoveAllForeignKeys=1;											-- Remove all FKs
-- EXEC [adm].[usp_ManageForeignKeys] @RemoveAllForeignKeys=1, @Directive='StoreDbsNewForeignKeys';		-- Remove all FKs (but store new ones fist!)
-- --EXEC [adm].[usp_ManageForeignKeys] @RemoveAllForeignKeys=1, @Directive='LooseDbsNewForeignKeys';	-- Remove all FKs (loose new ones) **CAREFULL**
------------------------------------------------
-- EXEC [adm].[usp_ManageForeignKeys] @ReAddAllForeignkeys=1;											-- Re-add stored FKs
-- EXEC [adm].[usp_ManageForeignKeys] @ReAddAllForeignkeys=1, @Directive='ReAddForeignKeysAnyway';		-- Re-add stored FKs (even thought there are new ones)
CREATE PROCEDURE [adm].[usp_ManageForeignKeys]

	@RemoveAllForeignKeys bit = 0,
	@ReAddAllForeignkeys bit = 0,
	@Directive nvarchar(500) = ''
	
AS
BEGIN
SET NOCOUNT ON;

	
	/*
	DROP TABLE [adm].[ForeignKeyDefinitions_bak];
	SELECT * INTO [adm].[ForeignKeyDefinitions_bak] FROM [adm].[ForeignKeyDefinitions];
	*/

	DECLARE @Now datetime = GETDATE();
	IF(@Directive IS NULL) SET @Directive = '';
	

	-- If it is missing, create the ForeignKeyDefinitions table needed to store ForeignKeys.
	-- CREATE SCHEMA adm;
	IF (NOT EXISTS(SELECT 1 FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[adm].[ForeignKeyDefinitions]'))) BEGIN
		CREATE TABLE [adm].[ForeignKeyDefinitions](
			[Id] int IDENTITY(1,1) NOT NULL,
			[DateCreated] datetime NOT NULL CONSTRAINT [DF_admForeignKeyDefinitions_CreateDate] DEFAULT (getdate()),
			[ParentSchema] nvarchar(20) NOT NULL,
			[ParentTable] nvarchar(100) NOT NULL,
			[ParentColumn] nvarchar(100) NOT NULL,
			[ReferencedSchema] nvarchar(20) NOT NULL,
			[ReferencedTable] nvarchar(100) NOT NULL,
			[ReferencedColumn] nvarchar(100) NOT NULL
		) ON [PRIMARY]
	END


	-- Pervent some logic inconsistencies.
	IF(@RemoveAllForeignKeys = 1 AND @ReAddAllForeignkeys = 1) BEGIN
		PRINT 'Error:  Parameters @RemoveAllForeignKeys and @ReAddAllForeignkeys can''t both be set to ''TRUE'' (can''t both remove and add all foreign keys).';
		GOTO EXIT_STORED_PROCEDURE;
	END


	-- Pre-Execution Statistics.
	DECLARE	@StoredFkCount int = (SELECT COUNT(*) FROM [adm].[ForeignKeyDefinitions]),
			@DbFkCount int = (SELECT COUNT(*) FROM sys.foreign_keys);
	PRINT '----- Manage Foreign Keys -----';
	PRINT 'Pre-Execution - Number of stored foreign keys (in [adm].[ForeignKeyDefinitions]): ' + CAST(@StoredFkCount as nvarchar(20));
	PRINT 'Pre-Execution - Number of foreign keys in this database: ' + ISNULL(CAST(@DbFkCount as nvarchar(20)), '<null>');
	PRINT '';
	

	-- Get a list of FKs currently active in the DB.
	DECLARE @FkInfo table (	[Fk] nvarchar(1000), [ParentSchema] nvarchar(20), [ParentTable] nvarchar(100), [ParentColumn] nvarchar(100), [ReferencedSchema] nvarchar(20), 
							[ReferencedTable] nvarchar(100), [ReferencedColumn] nvarchar(100), [ExistsInDb] bit, [IsStored] bit, [Description] nvarchar(1000),
							[CreateFkSql] nvarchar(1000), [DropFkSql] nvarchar(1000), [InsertIntoStoredSql] nvarchar(1000), [DeleteFromStoredSql] nvarchar(1000)	);
	INSERT INTO @FkInfo
		SELECT	Fk = SFK.[name],
				ParentSchema = SCHEMA_NAME(SOP.[schema_id]),
				ParentTable = OBJECT_NAME(SFK.[parent_object_id]),
				ParentColumn = COL_NAME(SFKC.[parent_object_id], SFKC.[parent_column_id]),
				ReferencedSchema = SCHEMA_NAME(SOR.[schema_id]),
				ReferencedTable = OBJECT_NAME(SFK.[referenced_object_id]),
				ReferencedColumn = COL_NAME(SFKC.[referenced_object_id], SFKC.[referenced_column_id]),
				ExistsInDb = 1,
				IsStored = 0,
				[Description] = NULL, 
				CreateFkSql = NULL, 
				DropFkSql = NULL, 
				InsertIntoStoredSql = NULL, 
				DeleteFromStoredSql = NULL
		FROM	sys.foreign_keys SFK
				INNER JOIN sys.foreign_key_columns SFKC
				 ON SFK.[object_id] = SFKC.[constraint_object_id]
				INNER JOIN sys.objects SOP
				 ON SFKC.[parent_object_id] = SOP.[object_id]
				INNER JOIN sys.objects SOR
				 ON SFKC.[referenced_object_id] = SOR.[object_id];


	-- Mark the Stored ones.
	UPDATE	DBFK
	SET		IsStored = 1
	FROM	@FkInfo DBFK
	WHERE	EXISTS (	SELECT	* 
						FROM	[adm].[ForeignKeyDefinitions]  FKD
						WHERE	FKD.ParentSchema = DBFK.ParentSchema
							AND	FKD.ParentTable = DBFK.ParentTable
							AND	FKD.ParentColumn = DBFK.ParentColumn
							AND	FKD.ReferencedSchema = DBFK.ReferencedSchema
							AND	FKD.ReferencedTable = DBFK.ReferencedTable
							AND	FKD.ReferencedColumn = DBFK.ReferencedColumn );


	-- Add any Stored that are not in the DB.
	INSERT INTO @FkInfo
		SELECT	Fk = LEFT('FK_' + [ParentSchema] + [ParentTable] + '_' + [ParentColumn] + '_' + [ReferencedSchema] + [ReferencedTable] + '_' + [ReferencedColumn], 128),
				ParentSchema, ParentTable, ParentColumn, ReferencedSchema, 
				ReferencedTable, ReferencedColumn, ExistsInDb=0, IsStored=1, [Description]=NULL,
				CreateFkSql=NULL, DropFkSql=NULL, InsertToStoreSql=NULL, DeleteFromStoreSql=NULL
		FROM	[adm].[ForeignKeyDefinitions] FKD
		WHERE	NOT EXISTS (	SELECT	*
								FROM	@FkInfo DBFK
								WHERE	DBFK.ParentSchema = FKD.ParentSchema
								  AND	DBFK.ParentTable = FKD.ParentTable
								  AND	DBFK.ParentColumn = FKD.ParentColumn
								  AND	DBFK.ReferencedSchema = FKD.ReferencedSchema
								  AND	DBFK.ReferencedTable = FKD.ReferencedTable
								  AND	DBFK.ReferencedColumn = FKD.ReferencedColumn );

	
	-- Populte all possible Sql.
	UPDATE	DBFK
	SET		[Description] = 'ParentSchema=''' + [ParentSchema] + '''; ParentTable=''' + [ParentTable] + '''; ParentColumn=''' + [ParentColumn] + '''; ReferencedSchema=''' + [ReferencedSchema] + '''; ReferencedTable=''' + [ReferencedTable] + '''; ReferencedColumn=''' + [ReferencedColumn] + '''',
			[CreateFkSql] = 'ALTER TABLE [' + [ParentSchema] + '].[' + [ParentTable] + '] WITH CHECK ADD CONSTRAINT [' + [Fk] + '] FOREIGN KEY([' + [ParentColumn] + ']) REFERENCES [' + [ReferencedSchema] + '].[' + [ReferencedTable] + '] ([' + [ReferencedColumn] + ']); ALTER TABLE [' + [ParentSchema] + '].[' + [ParentTable] + '] CHECK CONSTRAINT [' + [Fk] + '];',
			[DropFkSql] = 'ALTER TABLE [' + [ParentSchema] + '].[' + [ParentTable] + '] DROP CONSTRAINT [' + [Fk] + '];',
			[InsertIntoStoredSql] = 'INSERT INTO [adm].[ForeignKeyDefinitions] VALUES (''' + CONVERT(nvarchar, @Now, 121) + ''', ''' + [ParentSchema] + ''', ''' + [ParentTable] + ''', ''' + [ParentColumn] + ''', ''' + [ReferencedSchema] + ''', ''' + [ReferencedTable] + ''', ''' + [ReferencedColumn] + ''');',
			[DeleteFromStoredSql] = 'DELETE FROM [adm].[ForeignKeyDefinitions] WHERE [ParentSchema] = ''' + [ParentSchema] + ''' AND [ParentTable] = ''' + [ParentTable] + ''' AND [ParentColumn] = ''' + [ParentColumn] + ''' AND [ReferencedSchema] = ''' + [ReferencedSchema] + ''' AND [ReferencedTable] = ''' + [ReferencedTable] + ''' AND [ReferencedColumn] = ''' + [ReferencedColumn] + ''';'
	FROM	@FkInfo DBFK;


	-- Spit out info (if so directed).
	IF( (@RemoveAllForeignKeys=0) AND (@ReAddAllForeignkeys=0) AND (@Directive='')) BEGIN
		PRINT ' To gather info about ForeignKeys and stored ForeignKeys (in the [adm].[ForeignKeyDefinitions] table), run this stored';
		PRINT ' procedure with the @Directive argument set to ''JustShowFkInfoTable''.'
		GOTO EXIT_STORED_PROCEDURE;
	END
	IF(@Directive = 'JustShowFkInfoTable') BEGIN
		SELECT * FROM @FkInfo;
		GOTO EXIT_STORED_PROCEDURE;
	END


	-- Some info to make logic below more easy to read.
	DECLARE	@DbHasFKs bit = CASE WHEN ((SELECT COUNT(*) FROM @FkInfo WHERE [ExistsInDb]=1) > 0) THEN 1 ELSE 0 END,
			@DbHasStoredFKs bit = CASE WHEN ((SELECT COUNT(*) FROM @FkInfo WHERE [IsStored]=1) > 0) THEN 1 ELSE 0 END,
			@DbHasUnStoredFks bit = CASE WHEN ((SELECT COUNT(*) FROM @FkInfo WHERE [ExistsInDb]=1 AND [IsStored]=0) > 0) THEN 1 ELSE 0 END;


	-- Switchboard for removing all ForeignKeys.
	DECLARE @DoRemoveAll bit = 0, @StoreDbsNewFKs bit = 0, @DoReAddAll bit = 0;
	IF(@RemoveAllForeignKeys = 1) BEGIN

		IF( @DbHasFKs = 0 ) BEGIN
			PRINT ' * NOTE:	Nothing to do.  There are currenlty no ForeignKeys in this database.';
			GOTO EXIT_STORED_PROCEDURE;
		END
		IF( (@DbHasUnStoredFks = 1) AND (@Directive NOT IN ('StoreDbsNewForeignKeys', 'LooseDbsNewForeignKeys')) ) BEGIN
			PRINT ' * NOTE:	Can''t remove all ForeignKeys from this database because ForeignKeys exist in the database that have not been'
			PRINT '			saved to the [adm].[ForeignKeyDefinitions] table.  Options:  '
			PRINT '				1)	Set the @Directives argument to ''StoreDbsNewForeignKeys'' to store all non-stored ForeignKeys.';
			PRINT '				2)	Set the @Directives argument to ''LooseDbsNewForeignKeys'' to ignore all non-stored ForeignKeys (they will be lost).';
			GOTO EXIT_STORED_PROCEDURE;
		END ELSE IF( (@DbHasUnStoredFks = 1) AND (@Directive IN ('StoreDbsNewForeignKeys', 'LooseDbsNewForeignKeys')) ) BEGIN
			IF(@Directive = 'StoreDbsNewForeignKeys') BEGIN
				PRINT ' * NOTE: Saving all new ForeignKeys to the [adm].[ForeignKeyDefinitions] table (since @Directive is set to'
				PRINT '		''StoreDbsNewForeignKeys'').  Then removing all ForeignKeys from this database.'
				SET @StoreDbsNewFKs = 1;
			END ELSE BEGIN
				PRINT ' * NOTE: Ignoring all new ForeignKeys (since @Directive is set to ''LooseDbsNewForeignKeys'') and removing';
				PRINT '			all ForeignKeys from this database.  As a result, all ForeignKeys not in the [adm].[ForeignKeyDefinitions]';
				PRINT '			table will be lost.';
			END
			SET @DoRemoveAll = 1;
		END ELSE IF(@DbHasUnStoredFks = 0) BEGIN
			-- Most typical (the standard) situation when removing ForeignKeys.
			PRINT ' Removing all ForeignKeys from this database.  Since all ForeignKeys in this database have been stored in the'
			PRINT ' [adm].[ForeignKeyDefinitions] table, they can be re-added easily by calling this stored procedure with';
			PRINT ' @ReAddAllForeignkeys set to ''1''.';
			SET @DoRemoveAll = 1;
		END ELSE BEGIN
			PRINT ' ERROR:  Unabe to remove all ForeignKeys.  Unaticipated ForeignKey situation.';
			GOTO EXIT_STORED_PROCEDURE;
		END

	END


	-- Switchboard for re-adding all ForeignKeys.
	IF(@ReAddAllForeignkeys = 1) BEGIN

		IF( @DbHasStoredFKs = 0 ) BEGIN
			PRINT ' Nothing to do.  There is no stored ForeignKeys information in the [adm].[ForeignKeyDefinitions] table.';
			GOTO EXIT_STORED_PROCEDURE;
		END
		IF( (@DbHasFKs = 1) AND (@Directive != 'ReAddForeignKeysAnyway') ) BEGIN
			IF(@StoredFkCount != @DbFkCount) BEGIN
				PRINT ' * NOTE:	ForeignKeys currently exist in this database.  It is unusual to re-add ForeignKeys from information stored in';
				PRINT '			the [adm].[ForeignKeyDefinitions] table to a database with existing ForeignKeys.  If you wish to proceed, Set';
				PRINT '			the @Directives argument to ''ReAddForeignKeysAnyway''.';
			END ELSE BEGIN
				PRINT ' Nothing to do.  ForeignKeys exist in the database for all ' + CONVERT(nvarchar(20), @DbFkCount) + ' ForiegnKeys stored in'
				PRINT ' the [adm].[ForeignKeyDefinitions] table.';
			END
			GOTO EXIT_STORED_PROCEDURE;
		END ELSE  IF( (@DbHasFKs = 1) AND (@Directive = 'ReAddForeignKeysAnyway') ) BEGIN
			PRINT ' * NOTE:	A ForeignKey will be added for each row in the [adm].[ForeignKeyDefinitions] table.  ForeignKeys currenlty';
			PRINT '			exist in the database, so the [adm].[ForeignKeyDefinitions] table is out of synch with reality.';
			SET @DoReAddAll = 1;
		END ELSE IF( (@DbHasFKs = 0) ) BEGIN
			-- Most typical (the standard) situation when removing ForeignKeys.
			PRINT ' Re-creating all ForeignKeys in this database from information stored in the [adm].[ForeignKeyDefinitions] table.';
			PRINT ' Note: To prevent a stored ForeignKey from being re-created, delete its row from the [adm].[ForeignKeyDefinitions] table.';
			SET @DoReAddAll = 1;
		END ELSE BEGIN
			PRINT ' ERROR:  Unabe to re-add all ForeignKeys.  Unaticipated ForeignKey situation.';
			GOTO EXIT_STORED_PROCEDURE;
		END

	END


	-- Collect Sql to execute.
	DECLARE @Work table ([Type] nvarchar(20), [Fk] nvarchar(255), [Sql] nvarchar(1000));
	IF(@StoreDbsNewFKs = 1) BEGIN
		INSERT INTO @Work 
			SELECT	'InsertIntoStoredSql', [Fk], [InsertIntoStoredSql]
			FROM	@FkInfo
			WHERE	[ExistsInDb] = 1 AND [IsStored] = 0;
	END
	IF(@DoRemoveAll = 1) BEGIN
		INSERT INTO @Work 
			SELECT	'DropFkSql', [Fk], [DropFkSql]
			FROM	@FkInfo
			WHERE	[ExistsInDb] = 1;
	END
	IF(@DoReAddAll = 1) BEGIN
		INSERT INTO @Work 
			SELECT	'CreateFkSql', [Fk], [CreateFkSql]
			FROM	@FkInfo
			WHERE	[ExistsInDb] = 0 AND [IsStored] = 1;
	END


	-- Do synching work.
	PRINT '';
	DECLARE @DoneMsg nvarchar(500), @Type nvarchar(20), @Fk nvarchar(255), @Sql nvarchar(2000);
	DECLARE FkInfo_CURSOR CURSOR READ_ONLY
	FOR		SELECT	[Type], [Fk], [Sql]
			FROM	@Work
	OPEN FkInfo_CURSOR
	FETCH NEXT FROM FkInfo_CURSOR INTO @Type, @Fk, @Sql
	WHILE (@@fetch_status <> -1) BEGIN
		BEGIN TRY
			EXEC(@Sql);
			SET @DoneMsg =  CASE (@Type)
								WHEN 'InsertIntoStoredSql' THEN 'Stored foreign Key info in [adm].[ForeignKeyDefinitions]'
								WHEN 'DropFkSql' THEN 'Dropped foreign Key'
								WHEN 'CreateFkSql' THEN 'Created foreign Key'
								ELSE '{unknown work type}'
							END;
			PRINT '   ' + @DoneMsg + ':  ' + @Fk;
		END TRY
		BEGIN CATCH
			DECLARE @ErrMsg nvarchar(500) = ERROR_MESSAGE();
			RAISERROR(@ErrMsg, 16, -1);
			PRINT '   This ''' + @Type + ''' task failed due to above error: ' + @Sql
			IF(@Type = 'InsertIntoStoredSql') BEGIN 
				PRINT '   ***** Process halted since ForeignKey data could be lost if additional tasks are executed *****'
				GOTO EXIT_STORED_PROCEDURE;
			END
		END CATCH
		FETCH NEXT FROM FkInfo_CURSOR INTO @Type, @Fk, @Sql
	END
	CLOSE FkInfo_CURSOR DEALLOCATE FkInfo_CURSOR;

	-- Post-Execution Statistics.
	SET @StoredFkCount = (SELECT COUNT(*) FROM [adm].[ForeignKeyDefinitions]);
	SET @DbFkCount = (SELECT COUNT(*) FROM sys.foreign_keys);
	PRINT '';
	PRINT 'Post-Execution - Number of stored foreign keys (in [adm].[ForeignKeyDefinitions]): ' + CAST(@StoredFkCount as nvarchar(20));
	PRINT 'Post-Execution - Number of foreign keys in this database: ' + ISNULL(CAST(@DbFkCount as nvarchar(20)), '<null>');
	PRINT '';

	EXIT_STORED_PROCEDURE:
END



-- *************************************************************************
-- *****  *****
-- *************************************************************************
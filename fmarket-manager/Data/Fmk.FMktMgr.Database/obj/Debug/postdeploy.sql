/*
Post-Deployment Script Template							
--------------------------------------------------------------------------------------
 This file contains SQL statements that will be appended to the build script.		
 Use SQLCMD syntax to include a file in the post-deployment script.			
 Example:      :r .\myfile.sql								
 Use SQLCMD syntax to reference a variable in the post-deployment script.		
 Example:      :setvar TableName MyTable							
               SELECT * FROM [$(TableName)]					
--------------------------------------------------------------------------------------
*/



-- Having issues compiling these as a standard view (sys.tables stuff), deploying them this 
-- way for now (the views are set to not build).
DECLARE @TSql nvarchar(max) = '
CREATE VIEW [adm].[vDbColumnInfo] AS
	SELECT  [TableSchema] = SCHEMA_NAME(TBL.[schema_id]),
			[TableName] = TBL.[name],
			[IsLookupTable] = (CASE WHEN LEFT(TBL.[name], 2) = ''lk'' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[IsJoinTable] = (CASE WHEN LEFT(TBL.[name], 2) = ''jn'' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[ColumnId] = COL.[column_Id], 
			[ColumnName] = COL.[name], 
			[DataType] = TYP.[name], 
			[EntityDataType] = CASE TYP.[name]
								WHEN ''bigint''THEN ''long''			WHEN ''binary'' THEN ''byte[]''			WHEN ''bit'' THEN ''bool''						WHEN ''char'' THEN ''string''				WHEN ''date'' THEN ''DateTime''
								WHEN ''datetime'' THEN ''DateTime''		WHEN ''datetime2'' THEN ''DateTime''	WHEN ''datetimeoffset'' THEN ''DateTimeOffset''	WHEN ''decimal'' THEN ''decimal''			WHEN ''float'' THEN ''double''
								WHEN ''image'' THEN ''byte[]''			WHEN ''int'' THEN ''int''				WHEN ''money'' THEN ''decimal''					WHEN ''nchar'' THEN ''string''				WHEN ''ntext'' THEN ''string''
								WHEN ''numeric'' THEN ''decimal''		WHEN ''nvarchar'' THEN ''string''		WHEN ''real'' THEN ''float''					WHEN ''smalldatetime'' THEN ''DateTime''	WHEN ''smallint'' THEN ''short''
								WHEN ''smallmoney'' THEN ''decimal''	WHEN ''text'' THEN ''string''			WHEN ''time'' THEN ''TimeSpan''					WHEN ''timestamp'' THEN ''long''			WHEN ''tinyint'' THEN ''byte''
								WHEN ''uniqueidentifier'' THEN ''Guid''	WHEN ''varbinary'' THEN ''byte[]''		WHEN ''nvarchar'' THEN ''string''				ELSE ''UNKNOWN_'' + TYP.[name]
							END,
			[EntityFieldName] =	CASE 
									WHEN LEN(COL.[name]) > 2 AND RIGHT(COL.[name], 2) = ''Id'' COLLATE Latin1_General_CS_AS AND LEFT(COL.[name], 2) = ''lk'' COLLATE Latin1_General_CS_AS THEN SUBSTRING(SUBSTRING(COL.[name], 0, LEN(COL.[name])-1), 3, 9999)
									WHEN LEN(COL.[name]) > 2 AND RIGHT(COL.[name], 2) = ''Id'' COLLATE Latin1_General_CS_AS AND TYP.[name] LIKE ''%int'' THEN SUBSTRING(COL.[name], 0, LEN(COL.[name])-1)
									ELSE COL.[name]
								END,
			[IsIdentity] = COL.[is_identity], 
			[IsManaged] = (CASE WHEN (COL.[name] = ''DateCreated'' OR COL.[name] = ''LastUpdateBy'' OR COL.[name] = ''DateDeactivated'' OR COL.[name] = ''FlexData'') THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[IsComputed] = COL.[is_computed], 
			[DbMaxLength] = COL.[max_length], 
			[TextMaxLength] = (	CASE	WHEN (COL.[max_length]=-1) THEN -1 
										WHEN ((TYP.[name] LIKE ''%char%'' OR TYP.[name] LIKE ''%text%'') AND LEFT(TYP.[name], 1)!=''n'') THEN (COL.[max_length]) 
										WHEN ((TYP.[name] LIKE ''%char%'' OR TYP.[name] LIKE ''%text%'') AND LEFT(TYP.[name], 1)=''n'') THEN (COL.[max_length]/2) 
										ELSE NULL 
								END),
			[Precision] = COL.[Precision], 
			[Scale] = COL.[Scale], 
			[AllowNull] = COL.[is_nullable], 
			[DefaultValue] = SUBSTRING(CMT.[text], 2, LEN(CMT.[text]) - 2), 
			[FkName] = FK.[Name],
			[FkTableSchema] = SCHEMA_NAME(CTBL.schema_id),
			[FkTableName] = OBJECT_NAME(FKC.referenced_object_id),
			[FkTableColumn] = COL_NAME(FKC.referenced_object_id, FKC.referenced_column_id),
			[FkIsLookup] = (CASE WHEN LEFT(OBJECT_NAME(FKC.referenced_object_id), 2) = ''lk'' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END),
			[FkIsJoinTable] = (CASE WHEN LEFT(OBJECT_NAME(FKC.referenced_object_id), 2) = ''jn'' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END),
			[FkType] = (CASE WHEN FK.[Name] IS NULL THEN NULL WHEN FK.[Name] LIKE ''%_REF_%'' THEN ''Reference'' WHEN FK.[Name] LIKE ''%_PAR_%'' THEN ''Parent'' ELSE ''Unknown'' END)
	FROM	sys.tables TBL 
			INNER JOIN sys.columns COL ON TBL.[object_id] = COL.[object_id] AND TBL.[type] = ''U'' 
			INNER JOIN sys.types TYP ON Col.[system_type_id] = TYP.[system_type_id] AND Col.[user_type_id] = TYP.[user_type_id] 
			LEFT OUTER JOIN sys.syscomments CMT ON COL.[default_object_id] = CMT.[id]
			LEFT OUTER JOIN sys.foreign_key_columns FKC ON TBL.[object_id] = FKC.[parent_object_id] AND COL.[name] = COL_NAME(FKC.[parent_object_id], FKC.[parent_column_id])
			LEFT OUTER JOIN sys.foreign_keys FK ON FKC.constraint_object_id = FK.OBJECT_ID 
			LEFT OUTER JOIN sys.tables CTBL ON FKC.referenced_object_id = CTBL.OBJECT_ID
	WHERE	TBL.[is_ms_shipped] = 0
	  AND	TBL.[name] != ''sysdiagrams'';
	--ORDER BY SCHEMA_NAME(TBL.[schema_id]), TBL.[name], COL.[column_id];'
EXEC sp_executesql @TSql;

SET @TSql = '
CREATE VIEW [adm].[vDbIndexInfo] AS
	SELECT	[TableSchema]	=	SCHEMA_NAME(OBJ.[schema_id]),
			[TableName]		=	OBJ.[name],
			[IndexName]		=	IX.[name],
			[IsPrimaryKey]	=	IX.[is_primary_key],
			[IsClustered]	=	(CASE WHEN IX.[type] = 1 THEN 1 ELSE 0 END),
			[IsUnique]		=	IX.[is_unique_constraint],
			[Columns]		=	STUFF((	SELECT	'', ['' + COL.[name] + '']''
										FROM	sys.columns COL
												INNER JOIN sys.index_columns IXC ON IXC.[object_id] = COL.[object_id] AND IXC.[column_id] = COL.[column_id]
										WHERE	COL.[object_id] = OBJ.[object_id] 
										  AND	IXC.[index_id] = IX.[index_id] 
										  AND	IXC.[is_included_column] = 0
										ORDER BY key_ordinal
										FOR XML PATH('''')), 1, 2, ''''),
			[Includes]		=	STUFF((	SELECT	'', ['' + COL.[name] + '']''
										FROM	sys.columns COL
												INNER JOIN sys.index_columns IXC ON IXC.[object_id] = COL.[object_id] AND IXC.[column_id] = COL.[column_id]
										WHERE	COL.[object_id] = OBJ.[object_id]
										  AND	IXC.[index_id] = IX.[index_id]
										  AND	IXC.[is_included_column] = 1
										FOR XML PATH('''')), 1, 2, ''''),
			[IsDisabled]	=	IX.[is_disabled]
	FROM	sys.indexes IX
			INNER JOIN sys.objects OBJ ON OBJ.[object_id] = IX.[object_id] AND OBJ.[is_ms_shipped] = 0 -- Exclude objects created by internal component
	WHERE	OBJ.[type] = ''U''
	  AND	IX.[auto_created] = 0 -- Do not show auto-created IXs
	  --AND	IX.[is_unique_constraint] = 0 -- Enable to exclude UQ constraint IXs
	  AND	IX.[type] != 0 -- Exclude heaps
	  AND	OBJ.[name] != ''sysdiagrams''
	--ORDER BY SCHEMA_NAME(OBJ.[schema_id]), OBJ.[name], IX.[name];'
EXEC sp_executesql @TSql;



-- Error out if we have not conformed to the Foreign Key naming convention to designate relationship type.
IF ((SELECT COUNT(*) FROM [adm].[vDbColumnInfo] WHERE[FkName] IS NOT NULL AND [FkName] NOT LIKE '%_REF_%' AND [FkName] NOT LIKE '%_PAR_%') > 0) BEGIN
	RAISERROR ('All Foreign Keys must contain a relationship type designator: "_REF_" or "_PAR_". Use [adm].[vDbColumnInfo] to find the culprit(s)', 16 , -1);
END




-- Create TableAudit and triggers.
EXEC [adm].[usp_VerifyStandardTriggers];

-- Create indexes for columns involved in FKs and all pseudo-delete columns.
EXEC [adm].[usp_VerifyStandardIndexes];

-- Create all ubiquitous views.
EXEC [adm].[usp_CreateAllUbiquitousVeiws] 'dbo', 0;







INSERT INTO [dbo].[lkAddressType] ([Code],[Name],[Description])
     VALUES ('PRIM', 'Primary', 'Primary address'),
			('SHIP', 'Shipping', 'Shipping address'),
			('BILL', 'Billing', 'Billing address'),
			('HOME', 'Home', 'Home address'),
			('WORK', 'Work', 'Work address');



INSERT INTO [dbo].[lkCommentType] ([Code],[Name],[Description])
     VALUES ('GENRL', 'General', 'General comment'),
			('PEVNT', 'Post Event', 'Post event comment');



INSERT INTO [dbo].[lkCompanyType] ([Code],[Name],[Description])
     VALUES ('SUPLY', 'Supply', 'Supply company');



INSERT INTO [dbo].[lkContactItemType] ([Code],[Name],[Description])
     VALUES ('PHONE', 'Phone', 'Phone contact type'),
			('EMAIL', 'Email', 'Email contact type'),
			('URL', 'URL', 'URL contact type');



INSERT INTO [dbo].[lkEventRentType] ([Code],[Name],[Description])
     VALUES ('18PCT', '18 Percent', '18 percent of total'),
			('TT1', 'Tiered Type 1', 'Email contact type');



INSERT INTO [dbo].[lkEventType] ([Code],[Name],[Description])
     VALUES ('FRMKT', 'Farmer''s Market', 'Farmer''s market event type');



INSERT INTO [dbo].[lkGender] ([Code],[Name],[Description])
     VALUES ('M', 'Male', NULL),
			('F', 'Female', NULL),
			('U', 'Unknown', NULL);



INSERT INTO [dbo].[lkLocationType] ([Code],[Name],[Description])
     VALUES ('EVENT', 'Event', 'Event location'),
			('INVST', 'Inventory Storage', 'Inventory Storage location');



INSERT INTO [dbo].[lkPersonType] ([Code],[Name],[Description])
     VALUES ('VENDR', 'Vendor', 'Vendor persion type');



INSERT INTO [dbo].[lkInventoryTransactionType] ([Code],[Name],[Description])
     VALUES ('PRCHS', 'Purchase', 'Insert supply into inventory'),
			('ADJ', 'Adjustment', 'Adjust quantity of supply'),
			('ASSY', 'Assemble', 'Assemble a supply from other supply(s)'),
			('SOLD', 'Sold', 'Record sale of ')








DECLARE	@CoTypeId int = (SELECT TOP 1 [Id] FROM [dbo].[lkCompanyType])
INSERT INTO [dbo].[Company] ([Code], [Name], [CompanyTypeId], [IsApproved])
	VALUES ('A1', 'A1 Supply Co.', @CoTypeId, 1);

	


-- Not going to do a ProductType?  Use "child" SupplyType to define?
--INSERT INTO [dbo].[ProductType] ([OrganizationId], [Code],[Name],[Description])
--     VALUES (NULL, 'HONEY', 'Honey', NULL),
--			(NULL, 'TSHRT', 'T-Shirt', NULL)



INSERT INTO [dbo].[SupplyType] ([OrganizationId],[Code],[Name],[Description])
     VALUES (NULL, 'HNYCNTNR', 'Honey Container', 'Honey container'),
			(NULL, 'LABEL', 'Label', NULL),
			(NULL, 'HONEY', 'Honey', NULL);


DECLARE	@JarId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'HNYCNTNR'),
		@LblId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'LABEL'),
		@HnyId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'HONEY'),
		@CoId int = (SELECT TOP 1 [Id] FROM [dbo].[Company]);
INSERT INTO [dbo].[Supply] ([SupplyTypeId],[Code],[Name],[Description],[FromCompanyId],[Cost])
     VALUES (@JarId, 'JAR4OZ', 'Jar - 4oz', '4 ounce glass honey jar including lid', @CoId, 0.401),
			(@JarId, 'JAR10OZ', 'Jar - 10oz', '10 ounce glass honey jar including lid', @CoId, 0.6),
			(@JarId, 'JAR20OZ', 'Jar - 20oz', '20 ounce glass honey jar including lid', @CoId, 0.84),
			(@JarId, 'BEAR', 'Bear Container', 'Bear honey container', @CoId, 0.58),
			(@LblId, 'LBLBL4X2', 'Label - Blank - 4x2In', '4x2 inch blank label', @CoId, 0.016),
			(@LblId, 'LBLPR4X2', 'Label - Printed - 4x2In', '4x2 inch printed label', @CoId, NULL),
			(@LblId, 'LBLPR4X2', 'Label - Printed - 4x2In', '4x2 inch printed label', @CoId, NULL), 
			(@LblId, 'HNY10TRF', 'Honey 10ox Truffle', '10 oz truffle honey', @CoId, NULL), 
			(@LblId, 'HNY10TRF', 'Honey 10ox Truffle', '10 oz truffle honey', @CoId, NULL), 
			
			(@LblId, 'HNY10BBRY', 'Honey 10ox Blackberry', '10 oz blackberry honey', @CoId, NULL), 
			(@LblId, 'LBLPR4X2', 'Label - Printed - 4x2In', '4x2 inch printed label', @CoId, NULL), 
			(@LblId, 'LBLPR4X2', 'Label - Printed - 4x2In', '4x2 inch printed label', @CoId, NULL);




INSERT INTO [dbo].[VariationType] ([OrganizationId],[Code],[Name],[Description])
     VALUES (NULL, 'TSIZE', 'T-Shirt Size', 'T-shirt size variation'),
			(NULL, 'TCOLR', 'T-Shirt Color', 'T-shirt color variation');


DECLARE	@TSizeId int = (SELECT [Id] FROM [dbo].[VariationType] WHERE [Code] = 'TSIZE'),
		@TColorId int = (SELECT [Id] FROM [dbo].[VariationType] WHERE [Code] = 'TCOLR');
INSERT INTO [dbo].[Variation] ([VariationTypeId],[Code],[Name])
     VALUES (@TSizeId, 'TSZ_S', 'Small T-Shirt'),
			(@TSizeId, 'TSZ_M', 'Medium T-Shirt'),
			(@TSizeId, 'TSZ_L', 'Large T-Shirt'),
			(@TSizeId, 'TSZ_XL', 'Extra-Large T-Shirt'),
			(@TColorId, 'TCL_RED', 'Red T-Shirt'),
			(@TColorId, 'TCL_GRN', 'Green T-Shirt'),
			(@TColorId, 'TCL_BLU', 'Blue T-Shirt'),
			(@TColorId, 'TCL_GLD', 'Gold T-Shirt');
			
GO

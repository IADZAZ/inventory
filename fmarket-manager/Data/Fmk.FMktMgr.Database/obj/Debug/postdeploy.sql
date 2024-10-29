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
     VALUES ('SUPLY', 'Supply', 'Supply company'),
			('FMMGT', 'Farmers Market Management', 'Farmer''s market management company');



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
			('SOLD', 'Sold', 'Record sale'),
			('MOVE', 'Move', 'Move from one location to another');






			
-- [Company]
DECLARE	@SupCoId int = (SELECT [Id] FROM [dbo].[lkCompanyType] WHERE [Code] = 'SUPLY'),
		@MgmtCoId int = (SELECT [Id] FROM [dbo].[lkCompanyType] WHERE [Code] = 'FMMGT');
INSERT INTO [dbo].[Company] ([Code], [Name], [CompanyTypeId], [IsApproved])
	VALUES	('A1', 'A1 Supply Co.', @SupCoId, 1),
			('AHC', 'Awesome Honey Co.', @SupCoId, 1),
			('PFMM', 'Phoenix Farmer''s Market Mgmt', @MgmtCoId, 1),
			('MMM', 'M&M Management', @MgmtCoId, 1);
-- SELECT * FROM [dbo].[Company]
	


-- [Location]
DECLARE	@ILocId int = (SELECT [Id] FROM [dbo].[lkLocationType] WHERE [Code] = 'INVST'),
		@ELocId int = (SELECT [Id] FROM [dbo].[lkLocationType] WHERE [Code] = 'EVENT')
INSERT INTO [dbo].[Location] ([LocationTypeId], [Code], [Name])
	VALUES	(@ILocId, 'MOMBSMT', 'Mom''s Basement'),
			(@ELocId, '32Cactus', 'Farmer''s Market 32nd St & Cactus'),
			(@ELocId, 'PHXDT', 'Farmer''s Market Downtown Phoenix'),
			(@ELocId, 'MESA', 'Farmer''s Market Mesa'),
			(@ELocId, 'GOODYR', 'Farmer''s Market Goodyear');
-- SELECT * FROM [dbo].[Location]



-- [EventDefinition]
DECLARE	@MgmtCo1Id int = (SELECT [Id] FROM [dbo].[Company] WHERE [Code] = 'PFMM'),
		@MgmtCo2Id int = (SELECT [Id] FROM [dbo].[Company] WHERE [Code] = 'MMM'),
		@FMEvnetId int = (SELECT [Id] FROM [dbo].[lkEventType] WHERE [Code] = 'FRMKT'),
		@Loc32Id int = (SELECT [Id] FROM [dbo].[Location] WHERE [Code] = '32Cactus'),
		@LocPhxId int = (SELECT [Id] FROM [dbo].[Location] WHERE [Code] = 'PHXDT'),
		@LocMsaId int = (SELECT [Id] FROM [dbo].[Location] WHERE [Code] = 'MESA'),
		@LocGodId int = (SELECT [Id] FROM [dbo].[Location] WHERE [Code] = 'GOODYR'),
		@ERT1 int = (SELECT [Id] FROM [dbo].[lkEventRentType] WHERE [Code] = '18PCT'),
		@ERT2 int = (SELECT [Id] FROM [dbo].[lkEventRentType] WHERE [Code] = 'TT1');
INSERT INTO [dbo].[EventDefinition] (	[Code], [Name], [Description], [EventTypeId], [ManagementCompanyId], 
										[LocationId], [ScheduledStartTime], [ScheduledEndTime], [EventRentTypeId], [DefaultBoothSpace], 
										[DefaultPettyCash])
	VALUES	('32Cactus', 'Farmer''s Market 32nd St & Cactus', NULL, @FMEvnetId, @MgmtCo1Id, @Loc32Id, '0001-01-01 07:00:00 -07:00', '0001-01-01 13:00:00 -07:00', @ERT1, 'Row 2; Booth 12', 200),
			('PHXDT', 'Farmer''s Market Downtown Phoenix', NULL, @FMEvnetId, @MgmtCo2Id, @LocPhxId, '0001-01-01 08:00:00 -07:00', '0001-01-01 11:00:00 -07:00', @ERT2, 'Row 1; Booth 1', 180),
			('MESA', 'Farmer''s Market Mesa', NULL, @FMEvnetId, @MgmtCo1Id, @LocMsaId, '0001-01-01 07:30:00 -07:00', '0001-01-01 14:00:00 -07:00', @ERT1, 'Row 3; Booth 44', 300),
			('GOODYR', 'Farmer''s Market Goodyear', NULL, @FMEvnetId, @MgmtCo2Id, @LocGodId, '0001-01-01 07:15:00 -07:00', '0001-01-01 13:00:00 -07:00', @ERT2, 'Row 1; Booth 4', 300);
-- SELECT * FROM [dbo].[EventDefinition]




-- Not going to do a ProductType?  Use "child" SupplyType to define?
--INSERT INTO [dbo].[ProductType] ([OrganizationId], [Code],[Name],[Description])
--     VALUES (NULL, 'HONEY', 'Honey', NULL),
--			(NULL, 'TSHRT', 'T-Shirt', NULL)



-- [SupplyType]
INSERT INTO [dbo].[SupplyType] ([OrganizationId],[Code],[Name],[Description])
     VALUES (NULL, 'HNYCNTNR', 'Honey Container', 'Honey container'),
			(NULL, 'LABEL', 'Label', NULL),
			(NULL, 'HONEY', 'Honey', NULL);
-- SELECT * FROM [dbo].[SupplyType]


-- [Supply]
DECLARE	@JarId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'HNYCNTNR'),
		@LblId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'LABEL'),
		@HnyId int = (SELECT [Id] FROM [dbo].[SupplyType] WHERE [Code] = 'HONEY'),
		@CoId int = (SELECT TOP 1 [Id] FROM [dbo].[Company] WHERE [Code] = 'A1'),
		@HCoId int = (SELECT TOP 1 [Id] FROM [dbo].[Company] WHERE [Code] = 'AHC');
DISABLE TRIGGER [dbo].[Trigger_TableAudit_dboSupply] ON [dbo].[Supply];
SET IDENTITY_INSERT [dbo].[Supply] ON;
INSERT INTO [dbo].[Supply] ([Id], [SupplyTypeId],[Code],[Name],[Description],[FromCompanyId],[Cost])
     VALUES (1, @JarId, 'JAR4OZ', 'Jar - 4oz', '4 ounce glass honey jar including lid', @CoId, 0.401),
			(2, @JarId, 'JAR10OZ', 'Jar - 10oz', '10 ounce glass honey jar including lid', @CoId, 0.6),
			(3, @JarId, 'JAR20OZ', 'Jar - 20oz', '20 ounce glass honey jar including lid', @CoId, 0.84),
			(4, @JarId, 'BEAR', 'Bear Container', 'Bear honey container', @CoId, 0.58),
			(5, @LblId, 'LBLBL4X2', 'Label - Blank - 4x2In', '4x2 inch blank label', @CoId, 0.016),
			(6, @LblId, 'LBLPR4X2', 'Label - Printed - 4x2In', '4x2 inch printed label', @CoId, NULL),
			(7, @HnyId, 'HNY10TRFL', 'Honey 10oz Truffle', '10 oz truffle honey', @CoId, NULL), 
			(8, @HnyId, 'HNY10MSQT', 'Honey 10oz Mesquite', '10 oz mesquite honey', @CoId, NULL), 
			(9, @HnyId, 'HNY10BBRY', 'Honey 10oz Blackberry', '10 oz blackberry honey', @CoId, NULL), 
			(10, @HnyId, 'HNY10BLBR', 'Honey 10oz Blueberry', '10 oz blueberry honey', @CoId, NULL), 
			(11, @HnyId, 'HNY10CCNT', 'Honey 10oz Coconut', '10 oz coconut honey', @CoId, NULL),
			(12, @HnyId, 'T1HNY', 'Honey Type1 - 1oz', '1 oz type1 honey', @HCoId, NULL),
			(13, @HnyId, 'T2HNY', 'Honey Type2 - 1oz', '1 oz type2 honey', @HCoId, NULL),
			(14, @HnyId, 'T3HNY', 'Honey Type3 - 1oz', '1 oz type3 honey', @HCoId, NULL)
SET IDENTITY_INSERT [dbo].[Supply] OFF;
ENABLE TRIGGER [dbo].[Trigger_TableAudit_dboSupply] ON [dbo].[Supply];
-- SELECT * FROM [dbo].[Supply];


-- [SupplyChildSupply]
-- Create Supply hierarchy
-- Going to assume Ids for Supplies based on above:
INSERT INTO [dbo].[SupplyChildSupply] ([SupplyId], [ChildSupplyId], [ChildSupplyQuantity])
	VALUES	(6,5,1),	
			(7,2,1), (8,2,1), (9,2,1), (10,2,1), (11,2,1), 
			(7,6,1), (8,6,1), (9,6,1), (10,6,1), (11,6,1),
			(7,12,10), (8,13,10), (9,13,10), (10,14,10), (11,14,10);
-- SELECT * FROM [dbo].[SupplyChildSupply];



-- [Product]
INSERT INTO [dbo].[Product] ([SupplyId], [Price])
	VALUES	(7, 15), (8, 15.5), (9, 14.88), (10, 17), (11, 16.25)
-- SELECT * FROM [dbo].[Product];


-- [EventDefinitionProduct]
DECLARE @EventDefinitionId int = (SELECT MIN([Id]) FROM [dbo].[EventDefinition]),
		@ProductId int = (SELECT MIN([Id]) FROM [dbo].[Product]);
WHILE @EventDefinitionId IS NOT NULL
BEGIN
	SELECT @ProductId = MIN([Id]) FROM [dbo].[Product];
	WHILE @ProductId IS NOT NULL
	BEGIN
		INSERT INTO [dbo].[EventDefinitionProduct] ([EventDefinitionId], [ProductId], [Quantity])
			VALUES (@EventDefinitionId, @ProductId, 25+@EventDefinitionId+@ProductId )
		SELECT @ProductId = MIN([Id]) FROM [dbo].[Product] WHERE [Id] > @ProductId
	END
    SELECT @EventDefinitionId = MIN([Id]) FROM [dbo].[EventDefinition] WHERE [Id] > @EventDefinitionId
END
-- SELECT * FROM [dbo].[EventDefinitionProduct];



-- [VariationType]
INSERT INTO [dbo].[VariationType] ([OrganizationId],[Code],[Name],[Description])
     VALUES (NULL, 'TSIZE', 'T-Shirt Size', 'T-shirt size variation'),
			(NULL, 'TCOLR', 'T-Shirt Color', 'T-shirt color variation'),
			(NULL, 'JCOLR', 'Jar Color', 'Jar color variation');
-- SELECT * FROM [dbo].[VariationType];


-- [Variation]
DECLARE	@TSizeId int = (SELECT [Id] FROM [dbo].[VariationType] WHERE [Code] = 'TSIZE'),
		@TColorId int = (SELECT [Id] FROM [dbo].[VariationType] WHERE [Code] = 'TCOLR'),
		@JColorId int = (SELECT [Id] FROM [dbo].[VariationType] WHERE [Code] = 'JCOLR');
DISABLE TRIGGER [Trigger_TableAudit_dboVariation] ON [dbo].[Variation];
SET IDENTITY_INSERT [dbo].[Variation] ON;
INSERT INTO [dbo].[Variation] ([Id], [VariationTypeId],[Code],[Name])
     VALUES (1, @TSizeId, 'TSZ_S', 'Small T-Shirt'),
			(2, @TSizeId, 'TSZ_M', 'Medium T-Shirt'),
			(3, @TSizeId, 'TSZ_L', 'Large T-Shirt'),
			(4, @TSizeId, 'TSZ_XL', 'Extra-Large T-Shirt'),
			(5, @TColorId, 'TCL_RED', 'Red T-Shirt'),
			(6, @TColorId, 'TCL_GRN', 'Green T-Shirt'),
			(7, @TColorId, 'TCL_BLU', 'Blue T-Shirt'),
			(8, @TColorId, 'TCL_GLD', 'Gold T-Shirt'),
			(9, @TColorId, 'TCL_YLW', 'Yellow Jar'),
			(10, @TColorId, 'TCL_ORG', 'Orange Jar'),
			(11, @TColorId, 'TCL_PPL', 'Purple Jar');
SET IDENTITY_INSERT [dbo].[Variation] OFF;
ENABLE TRIGGER [Trigger_TableAudit_dboVariation] ON [dbo].[Variation];
-- SELECT * FROM [dbo].[Variation];


-- [jnSupplyVariation]
DECLARE	@VOrange int = (SELECT [Id] FROM [dbo].[Variation] WHERE [Code] = 'TCL_ORG'),
		@Purple int = (SELECT [Id] FROM [dbo].[Variation] WHERE [Code] = 'TCL_PPL');
INSERT INTO [dbo].[jnSupplyVariation] ([SupplyId], [VariationId])
	VALUES (10, @VOrange), (11, @Purple);
-- SELECT * FROM [dbo].[jnSupplyVariation];




DECLARE	@VendorTId int = (SELECT [Id] FROM [dbo].[lkPersonType] WHERE [Code] = 'VENDR'),
		@M int = (SELECT [Id] FROM [dbo].[lkGender] WHERE [Code] = 'M'),
		@F int = (SELECT [Id] FROM [dbo].[lkGender] WHERE [Code] = 'F');
INSERT INTO [dbo].[Person] ([PersonTypeId], [FirstName], [LastName], [GenderId])
	VALUES	(@VendorTId, 'Michael', 'Scott', @M),
			(@VendorTId, 'Dwight', 'Schrute', @M),
			(@VendorTId, 'Jim', 'Halpert', @M),
			(@VendorTId, 'Phyllis', 'Lapin-Vance', @F),
			(@VendorTId, 'Stanley', 'Hudson', @M);
-- SELECT * FROM [dbo].[v_Person];
GO

--***********************************************************************************
-- Note this view is not created in the destination database as it will not compile 
-- if [BuildAction] is set to 'Build'.
--***********************************************************************************
CREATE VIEW [adm].[vDbColumnInfo] AS
	SELECT  [TableSchema] = SCHEMA_NAME(TBL.[schema_id]),
			[TableName] = TBL.[name],
			[IsLookupTable] = (CASE WHEN LEFT(TBL.[name], 2) = 'lk' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[IsJoinTable] = (CASE WHEN LEFT(TBL.[name], 2) = 'jn' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[ColumnId] = COL.[column_Id], 
			[ColumnName] = COL.[name], 
			[DataType] = TYP.[name], 
			[EntityDataType] = CASE TYP.[name]
								WHEN 'bigint'THEN 'long'			WHEN 'binary' THEN 'byte[]'			WHEN 'bit' THEN 'bool'						WHEN 'char' THEN 'string'				WHEN 'date' THEN 'DateTime'
								WHEN 'datetime' THEN 'DateTime'		WHEN 'datetime2' THEN 'DateTime'	WHEN 'datetimeoffset' THEN 'DateTimeOffset'	WHEN 'decimal' THEN 'decimal'			WHEN 'float' THEN 'double'
								WHEN 'image' THEN 'byte[]'			WHEN 'int' THEN 'int'				WHEN 'money' THEN 'decimal'					WHEN 'nchar' THEN 'string'				WHEN 'ntext' THEN 'string'
								WHEN 'numeric' THEN 'decimal'		WHEN 'nvarchar' THEN 'string'		WHEN 'real' THEN 'float'					WHEN 'smalldatetime' THEN 'DateTime'	WHEN 'smallint' THEN 'short'
								WHEN 'smallmoney' THEN 'decimal'	WHEN 'text' THEN 'string'			WHEN 'time' THEN 'TimeSpan'					WHEN 'timestamp' THEN 'long'			WHEN 'tinyint' THEN 'byte'
								WHEN 'uniqueidentifier' THEN 'Guid'	WHEN 'varbinary' THEN 'byte[]'		WHEN 'varchar' THEN 'string'				ELSE 'UNKNOWN_' + TYP.[name]
							END,
			[EntityFieldName] =	CASE 
									WHEN LEN(COL.[name]) > 2 AND RIGHT(COL.[name], 2) = 'Id' COLLATE Latin1_General_CS_AS AND LEFT(COL.[name], 2) = 'lk' COLLATE Latin1_General_CS_AS THEN SUBSTRING(SUBSTRING(COL.[name], 0, LEN(COL.[name])-1), 3, 9999)
									WHEN LEN(COL.[name]) > 2 AND RIGHT(COL.[name], 2) = 'Id' COLLATE Latin1_General_CS_AS AND TYP.[name] LIKE '%int' THEN SUBSTRING(COL.[name], 0, LEN(COL.[name])-1)
									ELSE COL.[name]
								END,
			[IsIdentity] = COL.[is_identity], 
			[IsManaged] = (CASE WHEN (COL.[name] = 'DateCreated' OR COL.[name] = 'LastUpdateBy' OR COL.[name] = 'DateDeactivated' OR COL.[name] = 'FlexData') THEN CAST(1 as bit) ELSE CAST(0 as bit) END), 
			[IsComputed] = COL.[is_computed], 
			[DbMaxLength] = COL.[max_length], 
			[TextMaxLength] = (	CASE	WHEN (COL.[max_length]=-1) THEN -1 
										WHEN ((TYP.[name] LIKE '%char%' OR TYP.[name] LIKE '%text%') AND LEFT(TYP.[name], 1)!='n') THEN (COL.[max_length]) 
										WHEN ((TYP.[name] LIKE '%char%' OR TYP.[name] LIKE '%text%') AND LEFT(TYP.[name], 1)='n') THEN (COL.[max_length]/2) 
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
			[FkIsLookup] = (CASE WHEN LEFT(OBJECT_NAME(FKC.referenced_object_id), 2) = 'lk' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END),
			[FkIsJoinTable] = (CASE WHEN LEFT(OBJECT_NAME(FKC.referenced_object_id), 2) = 'jn' COLLATE Latin1_General_CS_AS THEN CAST(1 as bit) ELSE CAST(0 as bit) END),
			[FkType] = (CASE WHEN FK.[Name] IS NULL THEN NULL WHEN FK.[Name] LIKE '%_REF_%' THEN 'Reference' WHEN FK.[Name] LIKE '%_PAR_%' THEN 'Parent' ELSE 'Unknown' END)
	FROM	sys.tables TBL 
			INNER JOIN sys.columns COL ON TBL.[object_id] = COL.[object_id] AND TBL.[type] = 'U' 
			INNER JOIN sys.types TYP ON Col.[system_type_id] = TYP.[system_type_id] AND Col.[user_type_id] = TYP.[user_type_id] 
			LEFT OUTER JOIN sys.syscomments CMT ON COL.[default_object_id] = CMT.[id]
			LEFT OUTER JOIN sys.foreign_key_columns FKC ON TBL.[object_id] = FKC.[parent_object_id] AND COL.[name] = COL_NAME(FKC.[parent_object_id], FKC.[parent_column_id])
			LEFT OUTER JOIN sys.foreign_keys FK ON FKC.constraint_object_id = FK.OBJECT_ID 
			LEFT OUTER JOIN sys.tables CTBL ON FKC.referenced_object_id = CTBL.OBJECT_ID
	WHERE	TBL.[is_ms_shipped] = 0
	  AND	TBL.[name] != 'sysdiagrams';
	--ORDER BY SCHEMA_NAME(TBL.[schema_id]), TBL.[name], COL.[column_id];

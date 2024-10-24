--***********************************************************************************
-- Note this view is not created in the destination database as it will not compile 
-- if [BuildAction] is set to 'Build'.
--***********************************************************************************
CREATE VIEW [adm].[vDbIndexInfo] AS
	SELECT	[TableSchema]	=	SCHEMA_NAME(OBJ.[schema_id]),
			[TableName]		=	OBJ.[name],
			[IndexName]		=	IX.[name],
			[IsPrimaryKey]	=	IX.[is_primary_key],
			[IsClustered]	=	(CASE WHEN IX.[type] = 1 THEN 1 ELSE 0 END),
			[IsUnique]		=	IX.[is_unique_constraint],
			[Columns]		=	STUFF((	SELECT	', [' + COL.[name] + ']'
										FROM	sys.columns COL
												INNER JOIN sys.index_columns IXC ON IXC.[object_id] = COL.[object_id] AND IXC.[column_id] = COL.[column_id]
										WHERE	COL.[object_id] = OBJ.[object_id] 
										  AND	IXC.[index_id] = IX.[index_id] 
										  AND	IXC.[is_included_column] = 0
										ORDER BY key_ordinal
										FOR XML PATH('')), 1, 2, ''),
			[Includes]		=	STUFF((	SELECT	', [' + COL.[name] + ']'
										FROM	sys.columns COL
												INNER JOIN sys.index_columns IXC ON IXC.[object_id] = COL.[object_id] AND IXC.[column_id] = COL.[column_id]
										WHERE	COL.[object_id] = OBJ.[object_id]
										  AND	IXC.[index_id] = IX.[index_id]
										  AND	IXC.[is_included_column] = 1
										FOR XML PATH('')), 1, 2, ''),
			[IsDisabled]	=	IX.[is_disabled]
	FROM	sys.indexes IX
			INNER JOIN sys.objects OBJ ON OBJ.[object_id] = IX.[object_id] AND OBJ.[is_ms_shipped] = 0 -- Exclude objects created by internal component
	WHERE	OBJ.[type] = 'U'
	  AND	IX.[auto_created] = 0 -- Don't show auto-created IXs
	  --AND	IX.[is_unique_constraint] = 0 -- Enable to exclude UQ constaint IXs
	  AND	IX.[type] != 0 -- Exclude heaps
	  AND	OBJ.[name] != 'sysdiagrams'
	--ORDER BY SCHEMA_NAME(OBJ.[schema_id]), OBJ.[name], IX.[name];
GO
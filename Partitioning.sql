USE [WideWorldImportersDW];
GO

--Partitions (from table/index view)
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [i].[index_id] AS [IndexID], [i].[name] AS [IndexName], 
        [i].[type_desc] AS [IndexType], [p].[partition_number] AS [PartitionNumber], [p].[rows] AS [PartitionRows], 
        [p].[data_compression_desc] AS [PartitionCompression], [ps].[name] AS [PartitionScheme], [pf].[name] AS [PartitionFunctions], 
        [pf].[type_desc] + ' ' + CASE WHEN [pf].[boundary_value_on_right] = 1 THEN 'RIGHT' ELSE 'LEFT' END AS [PartitionFunctionType], 
        [ppt].[name] AS [Type], [pp].[max_length] AS [Length], [pp].[precision] AS [Precision], [pp].[scale] AS [Scale], 
        [pf].[fanout] AS [NumberOfRanges], [prv].[value] AS [PartitionBoundaryValue]
FROM    [sys].[schemas] [s]
JOIN    [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
JOIN    [sys].[indexes] [i] ON [i].[object_id] = [t].[object_id]
JOIN    [sys].[partitions] [p] ON [p].[object_id] = [i].[object_id] AND [p].[index_id] = [i].[index_id]
JOIN    [sys].[partition_schemes] [ps] ON [ps].[data_space_id] = [i].[data_space_id]
JOIN    [sys].[partition_functions] [pf] ON [pf].[function_id] = [ps].[function_id]
LEFT JOIN [sys].[partition_range_values] [prv] ON [prv].[function_id] = [pf].[function_id] AND [prv].[boundary_id] = [p].[partition_number]
JOIN    [sys].[partition_parameters] [pp] ON [pp].[function_id] = [pf].[function_id]
JOIN    [sys].[types] [ppt] ON [ppt].[user_type_id] = [pp].[user_type_id]
WHERE   [t].[object_id] = OBJECT_ID(N'Fact.Transaction')
ORDER BY [SchemaName], [TableName], [IndexType], [IndexName], [PartitionNumber];

--Partitions (from partition function view)
SELECT  [pf].[name] AS [PartitionFunction], [ps].[name] AS [PartitionScheme], [pf].[fanout] AS [NumberOfRanges], 
        [pf].[type_desc] + ' ' + CASE WHEN [pf].[boundary_value_on_right] = 1 THEN 'RIGHT' ELSE 'LEFT' END AS [PartitionFunctionType], 
        [ppt].[name] AS [Type], [pp].[max_length] AS [Length], [pp].[precision] AS [Precision], [pp].[scale] AS [Scale], 
        [prv].[MinValue], [prv].[MaxValue], 
        ISNULL(STUFF((
            SELECT  ', ' + QUOTENAME([s].[name]) + '.' + QUOTENAME([t].[name]) 
            FROM    [sys].[schemas] [s] JOIN [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
            JOIN    [sys].[indexes] [i] ON [i].[object_id] = [t].[object_id]
            WHERE   [i].[data_space_id] = [ps].[data_space_id]
            GROUP BY [s].[name], [t].[name]
            ORDER BY [s].[name], [t].[name]
            FOR XML PATH('')
        ), 1, 2, ''), 'Unused') AS [TablesOnThisSchemeAndFunction]
FROM    [sys].[partition_functions] [pf]
JOIN    [sys].[partition_schemes] [ps] ON [ps].[function_id] = [pf].[function_id]
JOIN    [sys].[partition_parameters] [pp] ON [pp].[function_id] = [pf].[function_id]
JOIN    [sys].[types] [ppt] ON [ppt].[user_type_id] = [pp].[user_type_id]
CROSS APPLY (
    SELECT MIN([prv].[value]) AS [MinValue], MAX([prv].[value]) AS [MaxValue] 
    FROM [sys].[partition_range_values] [prv] 
    WHERE [prv].[function_id] = [pf].[function_id]
) [prv];


USE [WideWorldImportersDW];
GO

--Physical data location
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [i].[index_id] AS [IndexID], [i].[type_desc] AS [IndexType], 
        [i].[name] AS [IndexName], [p].[partition_number] AS [PartitionNumber], [p].[rows] AS [PartitionRows], 
        [fg].[name] AS [FilegroupName], [df].[name] AS [DatabaseFileName], [df].[physical_name] AS [PhysicalFileName]
FROM    [sys].[schemas] [s]
JOIN    [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
JOIN    [sys].[indexes] [i] ON [i].[object_id] = [t].[object_id]
LEFT JOIN [sys].[data_spaces] [ds] ON [ds].[data_space_id] = [i].[data_space_id]
JOIN    [sys].[partitions] [p] ON [p].[object_id] = [i].[object_id] AND [p].[index_id] = [i].[index_id]
JOIN    [sys].[allocation_units] [au] ON [au].[container_id] = [p].[partition_id] AND [au].[type] = 1
LEFT JOIN [sys].[destination_data_spaces] [dds] ON [dds].[partition_scheme_id] = [i].[data_space_id] 
                                                AND [dds].[destination_id] = [p].[partition_number]
JOIN    [sys].[filegroups] [fg] ON [fg].[data_space_id] = COALESCE([dds].[data_space_id], [ds].[data_space_id], [au].[data_space_id])
LEFT JOIN [sys].[database_files] [df] ON [df].[data_space_id] = [fg].[data_space_id]
ORDER BY [SchemaName], [TableName], [IndexType], [IndexName], [PartitionNumber];

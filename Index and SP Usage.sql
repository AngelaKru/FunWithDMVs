USE [StackOverflow2013];
GO

--Index Usage
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [i].[index_id] AS [IndexID], [i].[name] AS [IndexName], 
        [i].[type_desc] AS [IndexType], [ius].[user_seeks] AS [Seeks], [ius].[user_scans] AS [Scans], [ius].[user_lookups] AS [Lookups], 
        [ius].[user_updates] AS [Updates],[ius].[last_user_seek] AS [LastSeek], [ius].[last_user_scan] AS [LastScan], 
        [ius].[last_user_lookup] AS [LastLookup], [ius].[last_user_update] AS [LastUpdate], 
        ISNULL(STUFF((SELECT ', ' + [c].[name]  FROM [sys].[columns] [c] 
                JOIN [sys].[index_columns] [ic] ON [ic].[object_id] = [c].[object_id] AND [ic].[column_id] = [c].[column_id]
                WHERE [ic].[object_id] = [i].[object_id] AND [ic].[index_id] = [i].[index_id] AND [ic].[key_ordinal] > 0
                ORDER BY [ic].[key_ordinal] FOR XML PATH('')), 1, 2, ''), '<HEAP>') AS [KeyColumns], 
        ISNULL(STUFF((SELECT ', ' + [c].[name]  FROM [sys].[columns] [c] 
                JOIN [sys].[index_columns] [ic] ON [ic].[object_id] = [c].[object_id] AND [ic].[column_id] = [c].[column_id]
                WHERE [ic].[object_id] = [i].[object_id] AND [ic].[index_id] = [i].[index_id] AND [ic].[is_included_column] = 1
                ORDER BY [c].[name] FOR XML PATH('')), 1, 2, ''), '') AS [IncludedColumns], 
        ISNULL(STUFF((SELECT ', ' + [c].[name] FROM [sys].[columns] [c] 
                JOIN [sys].[index_columns] [ic] ON [ic].[object_id] = [c].[object_id] AND [ic].[column_id] = [c].[column_id]
                WHERE [ic].[object_id] = [i].[object_id] AND [ic].[index_id] = [i].[index_id] AND [ic].[partition_ordinal] > 0
                ORDER BY [ic].[partition_ordinal] FOR XML PATH('')), 1, 2, ''), 'Not Partitioned') AS [PartitionKeys]
FROM    [sys].[schemas] [s]
JOIN    [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
JOIN    [sys].[indexes] [i] ON [i].[object_id] = [t].[object_id]
LEFT JOIN [sys].[dm_db_index_usage_stats] [ius] ON [ius].[database_id] = DB_ID() 
                                              AND [ius].[object_id] = [i].[object_id] 
                                              AND [ius].[index_id] = [i].[index_id]
ORDER BY [SchemaName], [TableName], [IndexType], [IndexName];

--Stored Procedure Usage
SELECT  [s].[name] AS [SchemaName], [p].[name] AS [ProcedureName], [ps].[sql_handle] AS [SQLHandle], [ps].[plan_handle] AS [PlanHandle], 
        [ps].[cached_time] AS [CachedTime], [ps].[last_execution_time] AS [LastExecTime], [ps].[execution_count] AS [ExecCount], 
        [ps].[total_worker_time] / 1000000.0 AS [TotalCPUSec], [ps].[total_worker_time] / [ps].[execution_count] / 1000000.0 AS [AvgCPUSec], 
        [ps].[total_elapsed_time] / 1000000.0 AS [TotalExecSec], [ps].[total_elapsed_time] / [ps].[execution_count]  / 1000000.0 AS [AvgExecSec]
FROM    [sys].[schemas] [s]
JOIN    [sys].[procedures] [p] ON [p].[schema_id] = [s].[schema_id]
LEFT JOIN [sys].[dm_exec_procedure_stats] [ps] ON [ps].[database_id] = DB_ID()
                                              AND [ps].[object_id] = [p].[object_id]
ORDER BY [SchemaName], [ProcedureName];

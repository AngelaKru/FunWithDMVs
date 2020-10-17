USE [StackOverflow2013]

--Table and Index Stats

--Autocreated column stats
DBCC SHOW_STATISTICS('dbo.Users', [_WA_Sys_00000009_08EA5793]) WITH STAT_HEADER, HISTOGRAM

SELECT  OBJECT_SCHEMA_NAME([s].[object_id]) + '.' + OBJECT_NAME([s].[object_id]) AS [object_name], 
        [s].[name] AS [stats_name], [c].[name] AS [column_name], [s].[stats_id], [s].[auto_created], [s].[user_created], 
        [sp].[last_updated], [sp].[rows], [sp].[rows_sampled], [sp].[steps], [sh].[step_number], 
        [sh].[range_high_key], [sh].[range_rows], [sh].[equal_rows], [sh].[distinct_range_rows], [sh].[average_range_rows]
FROM    [sys].[stats] [s] 
JOIN    [sys].[stats_columns] [sc] ON [sc].[object_id] = [s].[object_id] AND [sc].[stats_id] = [s].[stats_id]
JOIN    [sys].[columns] [c] ON [c].[object_id] = [sc].[object_id] AND [c].[column_id] = [sc].[column_id]
CROSS APPLY [sys].[dm_db_stats_histogram]([s].[object_id], [s].[stats_id]) [sh]
CROSS APPLY [sys].[dm_db_stats_properties]([s].[object_id], [s].[stats_id]) [sp]
WHERE   [s].[object_id] = OBJECT_ID(N'dbo.Users')
        AND [s].[name] = '_WA_Sys_00000009_08EA5793'
ORDER BY [sh].[step_number]

--Index stats
DBCC SHOW_STATISTICS('dbo.Users', [IX_LastAccessDate]) WITH STAT_HEADER, HISTOGRAM

SELECT  OBJECT_SCHEMA_NAME([s].[object_id]) + '.' + OBJECT_NAME([s].[object_id]) AS [object_name], 
        [s].[name] AS [stats_name], [c].[name] AS [column_name], [s].[stats_id], [s].[auto_created], [s].[user_created], 
        [sp].[last_updated], [sp].[rows], [sp].[rows_sampled], [sp].[steps], [sh].[step_number], 
        [sh].[range_high_key], [sh].[range_rows], [sh].[equal_rows], [sh].[distinct_range_rows], [sh].[average_range_rows]
FROM    [sys].[stats] [s] 
JOIN    [sys].[stats_columns] [sc] ON [sc].[object_id] = [s].[object_id] AND [sc].[stats_id] = [s].[stats_id]
JOIN    [sys].[columns] [c] ON [c].[object_id] = [sc].[object_id] AND [c].[column_id] = [sc].[column_id]
CROSS APPLY [sys].[dm_db_stats_histogram]([s].[object_id], [s].[stats_id]) [sh]
CROSS APPLY [sys].[dm_db_stats_properties]([s].[object_id], [s].[stats_id]) [sp]
WHERE   [s].[object_id] = OBJECT_ID(N'dbo.Users')
        AND [s].[name] = 'IX_LastAccessDate'
ORDER BY [sh].[step_number]

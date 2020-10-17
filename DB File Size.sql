USE [StackOverflow2013];
GO

--DB File Size
SELECT  [df].[type_desc] AS [FileType], [df].[name] AS [FileName], 
        [df].[physical_name] AS [PhysicalFileName], [df].[state_desc] AS [FileState], 
        CONVERT(decimal(18), [df].[size] * 8.0 / 1024) AS [FileSizeMB], 
        CONVERT(decimal(18), CASE WHEN [df].[max_size] < 0 THEN 2147483647 ELSE [df].[max_size] * 8.0 / 1024 END) AS [MaxFileSizeMB], 
        CASE WHEN [df].[is_percent_growth] = 1 THEN [df].[growth] END AS [FileGrowthPercent], 
        CONVERT(decimal(18), CASE WHEN [df].[is_percent_growth] = 0 THEN [df].[growth] * 8.0 / 1024 END) AS [FileGrowthMB], 
        CONVERT(decimal(28), [fsu].[total_page_count] * 8.0 / 1024) AS [TotalFileSizeMB], 
        CONVERT(decimal(28), [fsu].[allocated_extent_page_count] * 8.0 / 1024) AS [UsedFileSizeMB], 
        CONVERT(decimal(28), [fsu].[unallocated_extent_page_count] * 8.0 / 1024) AS [UnusedFileSizeMB], 
        CONVERT(decimal(5,2), [fsu].[allocated_extent_page_count] * 100.0 / [fsu].[total_page_count]) AS [UsedFilePercentMB], 
        CONVERT(decimal(5,2), [fsu].[unallocated_extent_page_count] * 100.0 / [fsu].[total_page_count]) AS [UnusedFilePercentMB]
FROM    [sys].[database_files] [df]
JOIN    [sys].[dm_db_file_space_usage] [fsu] ON [fsu].[file_id] = [df].[file_id]
UNION ALL
SELECT  [df].[type_desc] AS [FileType], [df].[name] AS [FileName], 
        [df].[physical_name] AS [PhysicalFileName], [df].[state_desc] AS [FileState], 
        CONVERT(decimal(18), [df].[size] * 8.0 / 1024) AS [FileSizeMB], 
        CONVERT(decimal(18), CASE WHEN [df].[max_size] < 0 THEN 2147483647 ELSE [df].[max_size] * 8.0 / 1024 END) AS [MaxFileSizeMB], 
        CASE WHEN [df].[is_percent_growth] = 1 THEN [df].[growth] END AS [FileGrowthPercent], 
        CONVERT(decimal(18), CASE WHEN [df].[is_percent_growth] = 0 THEN [df].[growth] * 8.0 / 1024 END) AS [FileGrowthMB], 
        CONVERT(decimal(28), [lsu].[total_log_size_in_bytes] / 1024.0 / 1024 / 1024) AS [TotalFileSize], 
        CONVERT(decimal(28), [lsu].[used_log_space_in_bytes] / 1024.0 / 1024 / 1024) AS [UsedFileSize], 
        CONVERT(decimal(28), ([lsu].[total_log_size_in_bytes] - [lsu].[used_log_space_in_bytes]) / 1024.0 / 1024 / 1024) AS [UnusedFileSize], 
        CONVERT(decimal(5,2), [lsu].[used_log_space_in_percent]) AS [UsedFilePercent], 
        CONVERT(decimal(5,2), ([lsu].[total_log_size_in_bytes] - [lsu].[used_log_space_in_bytes]) * 100.0 / [lsu].[total_log_size_in_bytes]) AS [UnusedFilePercent]
FROM    [sys].[database_files] [df]
CROSS JOIN [sys].[dm_db_log_space_usage] [lsu]
WHERE   [lsu].[database_id] = DB_ID()
        AND [df].[type_desc] = 'LOG'
ORDER BY [FileType] DESC, [FileName];

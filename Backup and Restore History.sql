USE [msdb];

--BACKUP DATABASE [StackOverflow2013] TO DISK = 'C:\Data\Backup\StackOverflow2013_Full_20201001.back' WITH INIT, COMPRESSION
--BACKUP DATABASE [StackOverflow2013] TO DISK = 'C:\Data\Backup\StackOverflow2013_Diff_20201001.back' WITH DIFFERENTIAL, COMPRESSION
--BACKUP LOG [StackOverflow2013] TO DISK = 'C:\Data\Backup\StackOverflow2013_Log_20201001_180000.trn' WITH COMPRESSION

--Backup History (Detail)
SELECT  [bs].[database_name] AS [DBName], [bs].[type] AS [BackupType], [bs].[compatibility_level] AS [DBCompatibility], 
        [bs].[backup_start_date] AS [StartDate], [bs].[backup_finish_date] AS [FinishDate], 
        [mf].[physical_device_name] AS [BackupFileName], [bs].[backup_size] / 1024.0 / 1024 AS [BackupSizeMB], 
        [bs].[compressed_backup_size] / 1024.0 / 1024 AS [BackupSizeCompressedMB]
FROM    [dbo].[backupset] [bs]
JOIN    [dbo].[backupmediafamily] [mf] ON [mf].[media_set_id] = [bs].[media_set_id]
WHERE   [bs].[database_name] = 'StackOverflow2013'
ORDER BY [DBName], [StartDate];

--Backup History (Summary/Latest)
SELECT  *, (SELECT MAX([Val].[LatestStartDate]) FROM (VALUES ([p].[D]), ([p].[I]), ([p].[L])) AS [Val]([LatestStartDate])) AS [LastBackup]
FROM    (
    SELECT  [bs].[database_name] AS [DBName], [bs].[type] AS [BackupType], [bs].[backup_start_date] AS [StartDate]
    FROM    [dbo].[backupset] [bs]
    WHERE   [bs].[database_name] = 'StackOverflow2013'
) [bh]
PIVOT (MAX([StartDate]) FOR [BackupType] IN ([D], [I], [L])) [p]
ORDER BY [p].[DBName];

--Restore History (Detail)
SELECT  [rh].[destination_database_name] AS [DBName], [rh].[restore_type] AS [BackupType], [bs].[compatibility_level] AS [DBCompatibility], 
        [rh].[restore_date] AS [RestoreDate], [bs].[backup_start_date] AS [StartDate], [bs].[backup_finish_date] AS [FinishDate], 
        [mf].[physical_device_name] AS [BackupFileName], [bs].[backup_size] / 1024.0 / 1024 AS [BackupSizeMB], 
        [bs].[compressed_backup_size] / 1024.0 / 1024 AS [BackupSizeCompressedMB]
--SELECT * 
FROM    [dbo].[restorehistory] [rh]
JOIN    [dbo].[backupset] [bs] ON [bs].[backup_set_id] = [rh].[backup_set_id]
JOIN    [dbo].[backupmediafamily] [mf] ON [mf].[media_set_id] = [bs].[media_set_id]
WHERE   [rh].[destination_database_name] = 'AdventureWorksDW'
ORDER BY [DBName], [StartDate];

--Restore History (Summary)
SELECT  *, (SELECT MAX([Val].[LatestStartDate]) FROM (VALUES ([p].[D]), ([p].[I]), ([p].[L])) AS [Val]([LatestStartDate])) AS [LastRestoredBackup]
FROM    (
    SELECT  [rh].[destination_database_name] AS [DBName], [rh].[restore_type] AS [BackupType], [bs].[backup_start_date] AS [StartDate]
    FROM    [dbo].[restorehistory] [rh]
    JOIN    [dbo].[backupset] [bs] ON [bs].[backup_set_id] = [rh].[backup_set_id]
    WHERE   [rh].[destination_database_name] = 'AdventureWorksDW'
) [bh]
PIVOT (MAX([StartDate]) FOR [BackupType] IN ([D], [I], [L])) [p]
ORDER BY [p].[DBName];

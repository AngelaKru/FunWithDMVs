USE [StackOverflow2013];
GO

--Table and Indes Size
WITH [IndexStats] AS (
    SELECT  [p].[object_id], [p].[index_id], SUM(CASE WHEN [p].[index_id] < 2 THEN [p].[rows] ELSE 0 END) AS [Rows], 
            SUM([pst].[reserved_page_count]) * 8 AS [ReservedKB], 
            SUM([pst].[used_page_count]) * 8 AS [UsedKB], 
            SUM([pst].[reserved_page_count] - [pst].[used_page_count]) * 8 AS [UnusedKB], 
            SUM(CASE WHEN ([pst].[index_id] < 2) 
                THEN ([pst].[in_row_data_page_count] + [pst].[lob_used_page_count] + [pst].[row_overflow_used_page_count]) ELSE 0 END) * 8 AS [DataKB]
    FROM    [sys].[partitions] [p]
    JOIN    [sys].[dm_db_partition_stats] [pst] ON [pst].[object_id] = [p].[object_id] 
                                                 AND [pst].[index_id] = [p].[index_id] 
                                                 AND [pst].[partition_number] = [p].[partition_number]
    GROUP BY [p].[object_id], [p].[index_id]
)
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [i].[index_id] AS [IndexID], [i].[name] AS [IndexName], 
        [i].[type_desc] AS [IndexType], 
        SUM([ist].[ReservedKB]) OVER(PARTITION BY [i].[object_id]) AS [ReservedTableKB], 
        SUM([ist].[UsedKB]) OVER(PARTITION BY [i].[object_id]) AS [UsedTableKB], 
        SUM([ist].[UnusedKB]) OVER(PARTITION BY [i].[object_id]) AS [UnusedTableKB], 
        SUM([ist].[DataKB]) OVER(PARTITION BY [i].[object_id]) AS [TableTotalDataKB], 
        SUM([ist].[UsedKB] - [ist].[DataKB]) OVER(PARTITION BY [i].[object_id]) AS [TableTotalIndexKB], 
        [ist].[UsedKB] AS [IndexKB]
FROM    [sys].[schemas] [s]
JOIN    [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
JOIN    [sys].[indexes] [i] ON [i].[object_id] = [t].[object_id]
JOIN    [IndexStats] [ist] ON [ist].[object_id] = [i].[object_id] AND [ist].[index_id] = [i].[index_id]
ORDER BY [SchemaName], [TableName], [IndexType], [IndexName];

EXEC [sys].[sp_spaceused] 'dbo.Posts'

/*
DECLARE @detail_tmp_table table(name nvarchar(128), rows bigint, reserved nvarchar(80), data nvarchar(80), index_size nvarchar(80), unused nvarchar(80)); 

SELECT
	@reservedpages = SUM (reserved_page_count),
	@usedpages = SUM (used_page_count),
	@pages = SUM (CASE WHEN (index_id < 2) THEN (in_row_data_page_count + lob_used_page_count + row_overflow_used_page_count) ELSE 0 END),
	@rowCount = SUM (CASE WHEN (index_id < 2) THEN row_count ELSE 0 END)
FROM sys.dm_db_partition_stats
WHERE object_id = @id;

INSERT INTO @detail_tmp_table (Name, Rows, Reserved, Data, Index, Unused)
SELECT
	OBJECT_NAME (@id) AS Name,
	CONVERT (char(20), @rowCount) AS Rows,
	LTRIM (STR (@reservedpages * 8, 15, 0) + ' KB') AS Reserved,
	LTRIM (STR (@pages * 8, 15, 0) + ' KB') AS Data,
	LTRIM (STR ((CASE WHEN @usedpages > @pages THEN (@usedpages - @pages) ELSE 0 END) * 8, 15, 0) + ' KB') AS Index,
	LTRIM (STR ((CASE WHEN @reservedpages > @usedpages THEN (@reservedpages - @usedpages) ELSE 0 END) * 8, 15, 0) + ' KB') AS Unused

----------------------------------------------------------------------------------------------------

select @reservedpages = sum(a.total_pages),
@usedpages = sum(a.used_pages),
@pages = sum(
		CASE
			-- XML-Index and FT-Index and semantic index internal tables are not considered "data", but is part of "index_size"
			When it.internal_type IN (202,204,207,211,212,213,214,215,216,221,222,236) Then 0
			When a.type <> 1 and p.index_id < 2 Then a.used_pages
			When p.index_id < 2 Then a.data_pages
			Else 0
		END
	)
from sys.system_internals_partitions p 
join sys.allocation_units a on p.partition_id = a.container_id

left join sys.internal_tables it on p.object_id = it.object_id
            
DECLARE @summary_tmp_table table(
			database_name nvarchar(128),
			database_size varchar(18),
			unallocated_space varchar(18),
			reserved varchar(18),
			data varchar(18),
			index_size varchar(18),
			unused varchar(18));

INSERT INTO @summary_tmp_table
			SELECT
				db_name(),
				LTRIM(STR((CONVERT (dec (15,2),@dbsize) + CONVERT (dec (15,2),@logsize) + 
					CONVERT (dec (15,2),CASE WHEN @ckptfilesize IS NOT NULL THEN @ckptfilesize ELSE 0 END)) *
					8192 / 1048576,15,2) + ' MB'),
				LTRIM(STR((CASE WHEN @dbsize >= @reservedpages THEN
					(CONVERT (dec (15,2),@dbsize) - CONVERT (dec (15,2),@reservedpages)) * 8192 / 1048576 ELSE 0 END) + 
					(CONVERT(dec (15,2), CASE WHEN @xtpprecreated IS NOT NULL THEN @xtpprecreated ELSE 0 END)) / 1048576,15,2) + ' MB'),
				LTRIM(STR(@reservedpages * 8192 / 1024.,15,0) + ' KB'),
				LTRIM(STR(@pages * 8192 / 1024.,15,0) + ' KB'),
				LTRIM(STR((@usedpages - @pages) * 8192 / 1024.,15,0) + ' KB'),
				LTRIM(STR((@reservedpages - @usedpages) * 8192 / 1024.,15,0) + ' KB')


*/

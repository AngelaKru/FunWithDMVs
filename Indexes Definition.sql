USE [StackOverflow2013];
GO

--Index Definition
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [i].[index_id] AS [IndexID], [i].[name] AS [IndexName], 
        CASE 
            WHEN [i].[is_primary_key] = 1 THEN 'PRIMARY KEY '
            WHEN [i].[is_unique_constraint] = 1 THEN 'UNIQUE CONSTRAINT ' 
            WHEN [i].[is_unique] = 1 THEN 'UNIQUE '
            WHEN [i].[is_hypothetical] = 1 THEN 'HYPOTHETICAL '
            ELSE ''
        END + [i].[type_desc] AS [IndexType], 
        CASE WHEN EXISTS (SELECT 1 FROM [sys].[key_constraints] [c] WHERE [c].[object_id] = [i].[object_id] AND [c].[is_system_named] = 1)
            OR EXISTS (SELECT 1 FROM [sys].[default_constraints] [c] WHERE [c].[object_id] = [i].[object_id] AND [c].[is_system_named] = 1)
            THEN 'Y' ELSE 'N' 
        END AS [IsSystemNamed], 
        STUFF((SELECT ', ' + [c].[name]  FROM [sys].[columns] [c] 
                JOIN [sys].[index_columns] [ic] ON [ic].[object_id] = [c].[object_id] AND [ic].[column_id] = [c].[column_id]
                WHERE [ic].[object_id] = [i].[object_id] AND [ic].[index_id] = [i].[index_id] AND [ic].[key_ordinal] > 0
                ORDER BY [ic].[key_ordinal] FOR XML PATH('')), 1, 2, '') AS [KeyColumns], 
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
WHERE   [t].[object_id] = OBJECT_ID(N'dbo.Users')
ORDER BY [SchemaName], [TableName], [i].[type_desc], [IndexName];

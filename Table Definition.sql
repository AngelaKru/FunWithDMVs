USE [StackOverflow2013];
GO

--Table Definition
SELECT  [s].[name] AS [SchemaName], [t].[name] AS [TableName], [t].[create_date] AS [TableCreateDate],
        [t].[modify_date] AS [LastModifiedDate], [c].[name] AS [ColumnName], [ct].[name] + 
        CASE 
            WHEN [ct].[name] IN ('char', 'varchar', 'binary', 'varbinary') 
                THEN ' (' + CASE WHEN [c].[max_length] < 0 THEN 'MAX' ELSE CONVERT(varchar, [c].[max_length]) + ')' END
            WHEN [ct].[name] IN ('nchar', 'nvarchar') 
                THEN ' (' + CASE WHEN [c].[max_length] < 0 THEN 'MAX' ELSE CONVERT(varchar, [c].[max_length] / 2) END + ')'
            WHEN [ct].[name] IN ('datetime', 'datetime2') 
                THEN '(' + CONVERT(varchar, [c].[scale]) + ')'
            WHEN [ct].[name] IN ('decimal', 'numeric') 
                THEN '(' + CONVERT(varchar, [c].[precision]) + ', ' + CONVERT(varchar, [c].[scale]) + ')'
            ELSE ''
        END AS [DataType], 
        CASE WHEN [c].[is_nullable] = 1 THEN 'NULL' ELSE 'NOT NULL' END AS [IsNullable]
FROM    [sys].[schemas] [s]
JOIN    [sys].[tables] [t] ON [t].[schema_id] = [s].[schema_id]
JOIN    [sys].[columns] [c] ON [c].[object_id] = [t].[object_id]
JOIN    [sys].[types] [ct] ON [ct].[user_type_id] = [c].[user_type_id]
WHERE   [t].[object_id] = OBJECT_ID(N'dbo.Posts')
ORDER BY [SchemaName], [TableName], [c].[column_id];

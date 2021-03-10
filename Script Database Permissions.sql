USE [dbname]
SELECT  DB_NAME() AS [db_name], [dp].[name], [dp].[type_desc], 
        ISNULL((
            SELECT  [p].[state_desc] + ' ' + [p].[permission_name] + 
                    CASE 
                        WHEN [p].[class_desc] = 'DATABASE' THEN ''
                        WHEN [p].[class_desc] = 'OBJECT_OR_COLUMN' AND [p].[major_id] > 0 THEN ' ON OBJECT::' + ISNULL(OBJECT_SCHEMA_NAME([p].[major_id]) + '.', '') + OBJECT_NAME([p].[major_id])
                        WHEN [p].[class_desc] = 'SCHEMA' THEN ' ON SCHEMA::' + SCHEMA_NAME([p].[major_id])
                        WHEN [p].[class_desc] = 'TYPE' THEN ' ON TYPE::' + TYPE_NAME([p].[major_id])
                        ELSE '!!!!! UNKNOWN !!!!!'
                    END + ' TO ' + QUOTENAME(ISNULL(SUSER_SNAME([p].[grantee_principal_id]), USER_NAME([p].[grantee_principal_id]))) + '; '
            FROM    [sys].[database_permissions] [p] 
            WHERE   [p].[grantee_principal_id] = [dp].[principal_id]
                    AND [p].[type] <> 'CO'
            GROUP BY [p].[state_desc], [p].[permission_name], [p].[class_desc], [p].[grantee_principal_id], [p].[major_id], [p].[class]
            ORDER BY [p].[class], [p].[state_desc], [p].[permission_name]
            FOR XML PATH('')
        ),'') AS [DirectPermissions], 
        ISNULL((
            SELECT  [p].[state_desc] + ' ' + [p].[permission_name] + 
                    CASE 
                        WHEN [p].[class_desc] = 'DATABASE' THEN ''
                        WHEN [p].[class_desc] = 'OBJECT_OR_COLUMN' AND [p].[major_id] > 0 THEN ' ON OBJECT::' + ISNULL(OBJECT_SCHEMA_NAME([p].[major_id]) + '.', '') + OBJECT_NAME([p].[major_id])
                        WHEN [p].[class_desc] = 'SCHEMA' THEN ' ON SCHEMA::' + SCHEMA_NAME([p].[major_id])
                        WHEN [p].[class_desc] = 'TYPE' THEN ' ON TYPE::' + TYPE_NAME([p].[major_id])
                        ELSE '!!!!! UNKNOWN !!!!!'
                    END + ' TO ' + QUOTENAME([r].[name]) + '; '
            FROM    [sys].[database_permissions] [p] 
            JOIN    [sys].[database_role_members] [drm] ON [drm].[role_principal_id] = [p].[grantee_principal_id]
            JOIN    [sys].[database_principals] [r] ON [r].[principal_id] = [drm].[role_principal_id]
            WHERE   [drm].[member_principal_id] = [dp].[principal_id]
            GROUP BY [p].[state_desc], [p].[permission_name], [p].[class_desc], [p].[grantee_principal_id], [p].[major_id], [p].[class], [r].[name]
            ORDER BY [p].[class], [p].[state_desc], [p].[permission_name]
            FOR XML PATH('')
        ),'') AS [IndirectPermissions]
FROM    [sys].[database_principals] [dp]
ORDER BY [dp].[type], [dp].[name];

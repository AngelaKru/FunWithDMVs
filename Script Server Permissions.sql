USE [master]
SELECT  p.name, p.type_desc, p.is_disabled, r.name, r.type_desc, 
(
SELECT sp.state_desc + ' ' + sp.[permission_name]
+ CASE 
    WHEN sp.class_desc = 'ENDPOINT' THEN ' ON ENDPOINT::' + (SELECT e.name FROM sys.endpoints e WHERE e.endpoint_id = sp.major_id)
    ELSE ''
END + ' TO ' + QUOTENAME(p.name) + '; '
FROM sys.server_permissions sp 
WHERE sp.grantee_principal_id = p.principal_id 
FOR XML PATH('')
) AS UserPermissions, 
(
SELECT sp.state_desc + ' ' + sp.[permission_name]
+ CASE 
    WHEN sp.class_desc = 'ENDPOINT' THEN ' ON ENDPOINT::' + (SELECT e.name FROM sys.endpoints e WHERE e.endpoint_id = sp.major_id)
    ELSE ''
END + ' TO ' + QUOTENAME(r.name) + '; '
FROM sys.server_permissions sp 
WHERE sp.grantee_principal_id = r.principal_id 
FOR XML PATH('')
) AS RolePermissions
FROM    sys.server_principals p
LEFT JOIN sys.server_role_members srm ON srm.member_principal_id = p.principal_id
LEFT JOIN sys.server_principals r ON r.principal_id = srm.role_principal_id
WHERE p.[is_fixed_role] = 0 AND p.[type] <> 'C'
ORDER BY p.[type_desc], p.name, r.name

USE [master]
SELECT  'IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = ''' + [name] + ''') CREATE LOGIN ['+[name]+'] WITH PASSWORD='+[master].[sys].[fn_varbintohexstr]([password_hash])+' HASHED, SID='+[master].[sys].[fn_varbintohexstr]([sid])+', DEFAULT_DATABASE=['+[default_database_name]+'], DEFAULT_LANGUAGE=['+[default_language_name]+'], CHECK_EXPIRATION='+CASE WHEN [is_expiration_checked] = 1 THEN 'ON' ELSE 'OFF' END+', CHECK_POLICY='+CASE WHEN [is_policy_checked] = 1 THEN 'ON' ELSE 'OFF' END+'; ', 
        * , PWDCOMPARE('clearpassword', [password_hash]) AS PwdCompare
FROM    [sys].[sql_logins] 

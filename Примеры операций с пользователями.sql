-- Просмотр всех пользователей и их ролей
USE StoreDB;
SELECT 
    princ.name AS UserName, 
    princ.type_desc AS UserType, 
    roles.name AS RoleName
FROM sys.database_principals princ
LEFT JOIN sys.database_role_members rm ON princ.principal_id = rm.member_principal_id
LEFT JOIN sys.database_principals roles ON rm.role_principal_id = roles.principal_id
WHERE princ.type IN ('S', 'U', 'G') -- SQL users, Windows users, Windows groups
ORDER BY princ.name;
GO

-- Просмотр разрешений для ролей
SELECT 
    roles.name AS RoleName,
    perm.permission_name AS Permission,
    perm.state_desc AS State,
    obj.name AS ObjectName,
    obj.type_desc AS ObjectType
FROM sys.database_principals roles
JOIN sys.database_permissions perm ON roles.principal_id = perm.grantee_principal_id
LEFT JOIN sys.objects obj ON perm.major_id = obj.object_id
WHERE roles.type = 'R' -- Roles
ORDER BY roles.name, perm.permission_name;
GO
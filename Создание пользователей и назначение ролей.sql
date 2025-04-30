-- Создание администратора с SQL Server аутентификацией
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'StoreAdmin')
BEGIN
    CREATE LOGIN StoreAdmin WITH PASSWORD = 'Admin@12345', 
    CHECK_POLICY = ON, 
    CHECK_EXPIRATION = ON,
    DEFAULT_DATABASE = StoreDB;
    
    USE StoreDB;
    CREATE USER StoreAdmin FOR LOGIN StoreAdmin;
    ALTER ROLE AdminRole ADD MEMBER StoreAdmin;
    ALTER SERVER ROLE sysadmin ADD MEMBER StoreAdmin;
END
GO

-- Создание кассира с SQL Server аутентификацией
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'Cashier1')
BEGIN
    CREATE LOGIN Cashier1 WITH PASSWORD = 'Cashier@2023', 
    CHECK_POLICY = ON, 
    CHECK_EXPIRATION = ON,
    DEFAULT_DATABASE = StoreDB;
    
    USE StoreDB;
    CREATE USER Cashier1 FOR LOGIN Cashier1;
    ALTER ROLE CashierRole ADD MEMBER Cashier1;
END
GO

-- Создание клиента с SQL Server аутентификацией
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'Customer1')
BEGIN
    CREATE LOGIN Customer1 WITH PASSWORD = 'Customer@2023', 
    CHECK_POLICY = ON, 
    CHECK_EXPIRATION = OFF,
    DEFAULT_DATABASE = StoreDB;
    
    USE StoreDB;
    CREATE USER Customer1 FOR LOGIN Customer1;
    ALTER ROLE CustomerRole ADD MEMBER Customer1;
END
GO

-- Создание пользователя Windows (если нужно)
-- EXEC sp_grantlogin 'DOMAIN\WindowsUser';
-- USE StoreDB;
-- CREATE USER [DOMAIN\WindowsUser] FOR LOGIN [DOMAIN\WindowsUser];
-- ALTER ROLE CustomerRole ADD MEMBER [DOMAIN\WindowsUser];
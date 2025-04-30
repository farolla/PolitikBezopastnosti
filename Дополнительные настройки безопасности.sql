-- Создание резервного администратора
IF NOT EXISTS (SELECT name FROM sys.server_principals WHERE name = 'BackupAdmin')
BEGIN
    CREATE LOGIN BackupAdmin WITH PASSWORD = 'B@ckup@12345', 
    CHECK_POLICY = ON, 
    CHECK_EXPIRATION = ON,
    DEFAULT_DATABASE = StoreDB;
    
    USE StoreDB;
    CREATE USER BackupAdmin FOR LOGIN BackupAdmin;
    ALTER ROLE AdminRole ADD MEMBER BackupAdmin;
    ALTER SERVER ROLE securityadmin ADD MEMBER BackupAdmin;
END
GO

-- Настройка аудита для административных действий
USE master;
GO

-- Используем стандартный путь для аудита
DECLARE @auditPath NVARCHAR(4000) = 'C:\Program Files\Microsoft SQL Server\MSSQL15.MSSQLSERVER\MSSQL\DATA\Audit\';


PRINT 'Используется путь для аудита: ' + ISNULL(@auditPath, 'не определен');

-- Создание аудита сервера (только если не существует)
IF NOT EXISTS (SELECT name FROM sys.server_audits WHERE name = 'AdminActionsAudit')
BEGIN
    -- Сначала создаем аудит
    DECLARE @sql NVARCHAR(MAX) = N'
    CREATE SERVER AUDIT AdminActionsAudit
    TO FILE (
        FILEPATH = ''' + @auditPath + ''',
        MAXSIZE = 100 MB,
        MAX_ROLLOVER_FILES = 10,
        RESERVE_DISK_SPACE = OFF
    )
    WITH (
        QUEUE_DELAY = 1000, 
        ON_FAILURE = CONTINUE
    );';
    
    BEGIN TRY
        EXEC sp_executesql @sql;
        
        -- Активируем аудит
        ALTER SERVER AUDIT AdminActionsAudit WITH (STATE = ON);
        
        -- Затем создаем спецификацию аудита сервера
        IF NOT EXISTS (SELECT name FROM sys.server_audit_specifications WHERE name = 'AdminLoginsSpec')
        BEGIN
            CREATE SERVER AUDIT SPECIFICATION AdminLoginsSpec
            FOR SERVER AUDIT AdminActionsAudit
            ADD (FAILED_LOGIN_GROUP),
            ADD (SUCCESSFUL_LOGIN_GROUP),
            ADD (LOGIN_CHANGE_PASSWORD_GROUP);
            
            ALTER SERVER AUDIT SPECIFICATION AdminLoginsSpec WITH (STATE = ON);
        END
    END TRY
    BEGIN CATCH
        PRINT 'Ошибка при создании аудита: ' + ERROR_MESSAGE();
    END CATCH
END
GO

USE StoreDB;
GO

-- Аудит изменений данных администраторами (только если аудит сервера существует)
IF EXISTS (SELECT name FROM sys.server_audits WHERE name = 'AdminActionsAudit')
BEGIN
    IF NOT EXISTS (SELECT name FROM sys.database_audit_specifications WHERE name = 'AdminDataChangesSpec')
    BEGIN
        BEGIN TRY
            CREATE DATABASE AUDIT SPECIFICATION AdminDataChangesSpec
            FOR SERVER AUDIT AdminActionsAudit
            ADD (INSERT, UPDATE, DELETE ON DATABASE::StoreDB BY AdminRole);
            
            ALTER DATABASE AUDIT SPECIFICATION AdminDataChangesSpec WITH (STATE = ON);
        END TRY
        BEGIN CATCH
            PRINT 'Ошибка при создании спецификации аудита базы данных: ' + ERROR_MESSAGE();
        END CATCH
    END
END
ELSE
BEGIN
    PRINT 'Аудит сервера AdminActionsAudit не существует, пропускаем создание спецификации базы данных';
END
GO
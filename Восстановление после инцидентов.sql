-- Пример: если администратор заблокирован, используем другой аккаунт для сброса
-- Только для экстренных случаев!
USE master;
GO

-- Разблокировка администратора (если пароль утерян)
-- Внимание: это нарушает политику безопасности, использовать только в крайних случаях
ALTER LOGIN StoreAdmin WITH PASSWORD = 'Temp@12345', CHECK_POLICY = OFF;
GO

-- После входа администратор должен немедленно сменить пароль на сложный
ALTER LOGIN StoreAdmin WITH 
    PASSWORD = 'NewSecure@Password123',
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON,
    MUST_CHANGE;
GO
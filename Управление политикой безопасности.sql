-- Изменение политики пароля для администратора (усиление безопасности)
ALTER LOGIN StoreAdmin WITH 
    CHECK_POLICY = ON,
    CHECK_EXPIRATION = ON;
    -- PASSWORD_EXPIRY_DATE не является допустимым параметром в ALTER LOGIN
    -- Для установки срока действия пароля используйте CHECK_EXPIRATION = ON
GO

-- Смена пароля кассира (правильный синтаксис)
-- Параметр OLD_PASSWORD не поддерживается в ALTER LOGIN, 
-- он используется только в sp_password (устаревшая процедура)
ALTER LOGIN Cashier1 WITH 
    PASSWORD = 'NewCashier@2024';
    -- Для смены пароля администратором старый пароль не требуется
GO

-- Если нужно сменить пароль, зная старый (только для текущего пользователя)
-- EXEC sp_password 'Cashier@2023', 'NewCashier@2024', 'Cashier1';

-- Отключение проверки политики пароля для клиента (если требуется)
ALTER LOGIN Customer1 WITH 
    CHECK_POLICY = OFF,
    CHECK_EXPIRATION = OFF;
GO

-- Отключение пользователя (например, временно)
ALTER LOGIN Cashier1 DISABLE;
GO

-- Включение пользователя обратно
ALTER LOGIN Cashier1 ENABLE;
GO

-- Удаление пользователя (пример)
-- Сначала удаляем из ролей и базы данных
USE StoreDB;
ALTER ROLE CashierRole DROP MEMBER Cashier1;
DROP USER Cashier1;
GO

-- Затем удаляем логин
USE master;
DROP LOGIN Cashier1;
GO
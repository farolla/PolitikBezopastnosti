-- Создание ролей для системы (Вариант 11: Администратор, Кассир, Клиент)
USE master;
GO

-- Создание базы данных для примера (если не существует)
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'StoreDB')
BEGIN
    CREATE DATABASE StoreDB;
END
GO

USE StoreDB;
GO

-- Создаем необходимые таблицы, если их нет
IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Products')
BEGIN
    CREATE TABLE Products (
        ProductID INT PRIMARY KEY,
        ProductName NVARCHAR(100),
        Price DECIMAL(10,2),
        StockQuantity INT
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Sales')
BEGIN
    CREATE TABLE Sales (
        SaleID INT PRIMARY KEY,
        ProductID INT REFERENCES Products(ProductID),
        CustomerID INT,
        SaleDate DATETIME,
        Quantity INT,
        TotalAmount DECIMAL(10,2)
    );
END

IF NOT EXISTS (SELECT * FROM sys.tables WHERE name = 'Customers')
BEGIN
    CREATE TABLE Customers (
        CustomerID INT PRIMARY KEY,
        CustomerName NVARCHAR(100),
        Email NVARCHAR(100),
        Phone NVARCHAR(20),
        UserLogin NVARCHAR(50) -- Поле для связи с логином пользователя
    );
END
GO

-- Создание роли Администратор с максимальными правами
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'AdminRole' AND type = 'R')
BEGIN
    CREATE ROLE AdminRole;
    GRANT CONTROL ON DATABASE::StoreDB TO AdminRole;
END
GO

-- Создание роли Кассир с правами на работу с продажами и товарами
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'CashierRole' AND type = 'R')
BEGIN
    CREATE ROLE CashierRole;
    GRANT SELECT, INSERT, UPDATE ON Products TO CashierRole;
    GRANT SELECT, INSERT ON Sales TO CashierRole;
    GRANT SELECT ON Customers TO CashierRole;
    GRANT EXECUTE ON SCHEMA::dbo TO CashierRole;
END
GO

-- Создание роли Клиент с ограниченными правами
IF NOT EXISTS (SELECT name FROM sys.database_principals WHERE name = 'CustomerRole' AND type = 'R')
BEGIN
    CREATE ROLE CustomerRole;
    GRANT SELECT ON Products TO CustomerRole;
    
    -- Для ограничения доступа клиентов только к своим данным используем представление
    IF NOT EXISTS (SELECT * FROM sys.views WHERE name = 'v_CustomerSelfData')
    BEGIN
        EXEC('CREATE VIEW v_CustomerSelfData AS 
              SELECT * FROM Customers 
              WHERE UserLogin = USER_NAME()');
    END
    
    GRANT SELECT, UPDATE ON v_CustomerSelfData TO CustomerRole;
END
GO
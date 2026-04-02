CREATE DATABASE Customers_transactions;
UPDATE customers SET Gender = NULL WHERE Gender = '';
UPDATE customers SET Age = NULL WHERE Age = '';
ALTER TABLE customers modify Age INT NULL;

SELECT * FROM customers;
SELECT * FROM transactions;

CREATE TABLE Transactions
(date_new DATE,
Id_check INT,
ID_client INT,
Count_products DECIMAL(10,3),
Sum_payment DECIMAL(10,2));

LOAD DATA INFILE "C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\TRANSACTIONS_final.csv"
INTO TABLE transactions
FIELDS TERMINATED BY ','
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

SHOW VARIABLES LIKE 'secure_file_priv';

# 1 задания
WITH ClientStats AS (
    SELECT 
        ID_client,
        COUNT(DISTINCT DATE_FORMAT(date_new, '%Y-%m')) as active_months,
        AVG(Sum_payment) as avg_check, -- средний чек за период
        SUM(Sum_payment) as total_sum,
        COUNT(Id_check) as total_ops    -- количество операций
    FROM transactions
    WHERE date_new BETWEEN '2015-06-01' AND '2016-06-01'
    GROUP BY ID_client
)
SELECT * FROM ClientStats 
WHERE active_months = 13; -- 13 месяцев, если считаем включительно оба июня

# 2 задания
SELECT 
    DATE_FORMAT(t.date_new, '%Y-%m') AS month,
    AVG(t.Sum_payment) AS avg_monthly_check,      -- (a) средний чек в месяц
    COUNT(t.Id_check) / COUNT(DISTINCT t.ID_client) AS avg_ops_per_client, -- (b) среднее кол-во операций
    COUNT(DISTINCT t.ID_client) AS active_clients, -- (c) среднее кол-во клиентов
    -- (e) Соотношение полов и их доля в затратах
    COUNT(CASE WHEN c.Gender = 'M' THEN 1 END) * 100.0 / COUNT(*) AS male_pct,
    COUNT(CASE WHEN c.Gender = 'F' THEN 1 END) * 100.0 / COUNT(*) AS female_pct,
    SUM(CASE WHEN c.Gender = 'M' THEN t.Sum_payment ELSE 0 END) / SUM(t.Sum_payment) * 100 AS male_spend_share
FROM transactions t
LEFT JOIN customers c ON t.ID_client = c.Id_client
WHERE t.date_new BETWEEN '2015-06-01' AND '2016-06-01'
GROUP BY 1;

# 3 задания
SELECT 
    CASE 
        WHEN Age IS NULL THEN 'Нет данных'
        ELSE CONCAT(FLOOR(Age/10)*10, '-', FLOOR(Age/10)*10 + 9) 
    END AS age_group,
    SUM(Sum_payment) AS total_sum,
    COUNT(Id_check) AS total_ops,
    -- Средние показатели за квартал (пример расчета)
    SUM(Sum_payment) / 4 AS avg_quarter_sum
FROM transactions t
LEFT JOIN customers c ON t.ID_client = c.Id_client
GROUP BY 1;
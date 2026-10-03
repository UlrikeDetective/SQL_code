-- costumer

select * from customers;

SELECT 
    gender,
    COUNT(*) AS anzahl,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS prozent
FROM customers
GROUP BY gender
ORDER BY anzahl DESC;

SELECT 
    COALESCE(gender, 'Nicht angegeben') AS gender,
    COUNT(*) AS anzahl,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS prozent
FROM customers
GROUP BY gender
ORDER BY anzahl DESC;

ALTER TABLE customers 
ADD COLUMN birthday DATE;

UPDATE customers
SET birthday = CASE 
    -- 70% Wahrscheinlichkeit: Alter 23 bis 38 Jahre (1987-10-04 bis 2003-10-03)
    WHEN RANDOM() < 0.7 THEN 
        '1987-10-04'::DATE + (RANDOM() * ('2003-10-03'::DATE - '1987-10-04'::DATE))::INT
    -- 30% Wahrscheinlichkeit: Restlicher Zeitraum (1963-01-01 bis 2008-10-03)
    ELSE 
        '1963-01-01'::DATE + (RANDOM() * ('2008-10-03'::DATE - '1963-01-01'::DATE))::INT
END;
-- costumer

SELECT 
    gender,
    COUNT(*) AS anzahl,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (), 2) AS prozent
FROM customers
GROUP BY gender
ORDER BY anzahl DESC;
INSERT INTO event_registrations (event_id, customer_id, registered_at)
WITH surf_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN books b ON oi.book_id = b.id
    WHERE b.title ILIKE '%Carissa%'
)
SELECT 
    260 AS event_id,
    sc.customer_id,
    CURRENT_TIMESTAMP AS registered_at
FROM surf_customers sc
LEFT JOIN event_registrations er 
       ON er.event_id = 260 
      AND er.customer_id = sc.customer_id
WHERE er.customer_id IS NULL  -- Exclude already registered customers
  AND RANDOM() < 0.95;         -- Pick roughly 50% of eligible customers


  INSERT INTO event_registrations (event_id, customer_id, registered_at)
WITH surf_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN books b ON oi.book_id = b.id
    WHERE b.hashtags ILIKE '%surfing%'
)
SELECT 
    260 AS event_id,
    sc.customer_id,
    CURRENT_TIMESTAMP AS registered_at
FROM surf_customers sc
LEFT JOIN event_registrations er 
       ON er.event_id = 260 
      AND er.customer_id = sc.customer_id
WHERE er.customer_id IS NULL  -- Exclude already registered customers
  AND RANDOM() < 0.25;         -- Pick roughly 50% of eligible customers
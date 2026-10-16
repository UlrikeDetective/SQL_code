INSERT INTO event_registrations (event_id, customer_id, registered_at)
WITH surf_customers AS (
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN books b ON oi.book_id = b.id
    WHERE b.title ILIKE '%Sankofa%'
)
SELECT 
    85 AS event_id,
    sc.customer_id,
    CURRENT_TIMESTAMP AS registered_at
FROM surf_customers sc
LEFT JOIN event_registrations er 
       ON er.event_id = 85 
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
    236 AS event_id,
    sc.customer_id,
    CURRENT_TIMESTAMP AS registered_at
FROM surf_customers sc
LEFT JOIN event_registrations er 
       ON er.event_id = 236 
      AND er.customer_id = sc.customer_id
WHERE er.customer_id IS NULL  -- Exclude already registered customers
  AND RANDOM() < 0.25;         -- Pick roughly 50% of eligible customers

-- buy books
WITH selected_customers AS (
    -- 1. Identify all unique customers who have purchased a book with #reese
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN books b ON oi.book_id = b.id
    WHERE b.hashtags ILIKE '%reese%'
),
eligible_customers AS (
    -- 2. Filter out ANY customer who has EVER purchased book_id = 389 in the past
    SELECT sc.customer_id
    FROM selected_customers sc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM orders o_past
        JOIN order_items oi_past ON o_past.id = oi_past.order_id
        WHERE o_past.customer_id = sc.customer_id
          AND oi_past.book_id = 389
    )
    AND RANDOM() < 0.5 -- Pick roughly 50% of remaining eligible customers
),
new_orders AS (
    -- 3. Create orders with total_amount set directly to the book price
    INSERT INTO orders (customer_id, order_date, total_amount)
    SELECT 
        ec.customer_id, 
        CURRENT_TIMESTAMP,
        b.price
    FROM eligible_customers ec
    CROSS JOIN books b
    WHERE b.id = 389
    RETURNING id AS order_id
)
-- 4. Create the corresponding order items
INSERT INTO order_items (order_id, book_id, quantity, unit_price)
SELECT 
    no.order_id,
    389 AS book_id,
    1 AS quantity,
    b.price AS unit_price
FROM new_orders no
CROSS JOIN books b
WHERE b.id = 389;
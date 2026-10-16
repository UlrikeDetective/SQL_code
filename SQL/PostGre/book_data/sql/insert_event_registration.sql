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


-- 1. Create the trigger function
CREATE OR REPLACE FUNCTION update_book_stock_on_order()
RETURNS TRIGGER AS $$
BEGIN
    -- Check if sufficient stock exists
    IF (SELECT stock_quantity FROM books WHERE id = NEW.book_id) < NEW.quantity THEN
        RAISE EXCEPTION 'Insufficient stock for book ID %', NEW.book_id;
    END IF;

    -- Deduct stock_quantity
    UPDATE books
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE id = NEW.book_id;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- 2. Attach the trigger to the order_items table
CREATE TRIGGER trigger_reduce_book_stock
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_book_stock_on_order();

-- buy books
WITH selected_customers AS (
    -- 1. Identify all unique customers who bought a book with #reese
    SELECT DISTINCT o.customer_id
    FROM orders o
    JOIN order_items oi ON o.id = oi.order_id
    JOIN books b ON oi.book_id = b.id
    WHERE b.hashtags ILIKE '%reese%'
),
eligible_customers AS (
    -- 2. Exclude customers who already bought book 389 and pick ~50%
    SELECT sc.customer_id
    FROM selected_customers sc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM orders o_past
        JOIN order_items oi_past ON o_past.id = oi_past.order_id
        WHERE o_past.customer_id = sc.customer_id
          AND oi_past.book_id = 389
    )
    AND RANDOM() < 0.1
),
new_orders AS (
    -- 3. Create the orders with total_amount
    INSERT INTO orders (customer_id, order_date, total_amount)
    SELECT 
        ec.customer_id, 
        CURRENT_TIMESTAMP,
        b.price
    FROM eligible_customers ec
    CROSS JOIN books b
    WHERE b.id = 389 AND b.stock_quantity >= 1 -- Ensure book is in stock
    RETURNING id AS order_id
),
inserted_items AS (
    -- 4. Create order items
    INSERT INTO order_items (order_id, book_id, quantity, unit_price)
    SELECT 
        no.order_id,
        389 AS book_id,
        1 AS quantity,
        b.price AS unit_price
    FROM new_orders no
    CROSS JOIN books b
    WHERE b.id = 389
    RETURNING book_id, quantity
)
-- 5. Deduct stock_quantity in the books table for the purchased items
UPDATE books
SET stock_quantity = stock_quantity - sub.total_purchased
FROM (
    SELECT book_id, SUM(quantity) AS total_purchased
    FROM inserted_items
    GROUP BY book_id
) sub
WHERE books.id = sub.book_id;
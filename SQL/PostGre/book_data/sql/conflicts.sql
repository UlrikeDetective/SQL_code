-- conficts

-- 1. Remove duplicate authors keeping the one with the lowest ID
DELETE FROM authors a1
USING authors a2
WHERE a1.id > a2.id
  AND a1.first_name = a2.first_name
  AND a1.last_name = a2.last_name;

-- 2. Add a UNIQUE constraint on first_name and last_name
ALTER TABLE authors 
ADD CONSTRAINT unique_author_name UNIQUE (first_name, last_name);

INSERT INTO authors (first_name, last_name, bio)
VALUES
  ('Anne-Laure', 'Le Cunff', 'Neuroscientist and founder of Ness Labs.'),
  ('Chris', 'Voss', 'Former FBI hostage negotiator and author.'),
  ('Nao-Cola', 'Yamazaki', 'Acclaimed Japanese novelist and essayist.')
ON CONFLICT (first_name, last_name) 
DO UPDATE SET bio = EXCLUDED.bio 
WHERE authors.bio IS NULL OR authors.bio = '';

-- Add constraint (make sure to clean up duplicates like Option A first)
ALTER TABLE books 
ADD CONSTRAINT unique_book_title_author UNIQUE (title, author_id);

BEGIN;

-- 1. Merge stock quantity and update hashtags on row 490
UPDATE books
SET 
  stock_quantity = stock_quantity + (SELECT stock_quantity FROM books WHERE id = 897),
  hashtags = '#barackobamareading #family #southernfiction #friendship #neighbors #sisters #usa #americansouth'
WHERE id = 490;

-- 2. Delete the duplicate row
DELETE FROM books WHERE id = 897;

COMMIT;

-- Find duplicate authors
SELECT 
    first_name, 
    last_name, 
    COUNT(*) AS count,
    ARRAY_AGG(id) AS author_ids
FROM authors
GROUP BY first_name, last_name
HAVING COUNT(*) > 1;

-- Find duplicate books (same author)
SELECT 
    b.title, 
    a.first_name, 
    a.last_name, 
    COUNT(*) AS count,
    ARRAY_AGG(b.id) AS book_ids,
    ARRAY_AGG(b.isbn) AS isbns
FROM books b
JOIN authors a ON b.author_id = a.id
GROUP BY b.title, a.first_name, a.last_name
HAVING COUNT(*) > 1;

-- Find Duplicate Books by Title Only
SELECT 
    title, 
    COUNT(*) AS count,
    ARRAY_AGG(id) AS book_ids,
    ARRAY_AGG(isbn) AS isbns
FROM books
GROUP BY title
HAVING COUNT(*) > 1;

-- How to Automatically Clean Up Duplicate Books
DELETE FROM books b1
USING books b2
WHERE b1.id > b2.id
  AND b1.title = b2.title
  AND b1.author_id = b2.author_id;

-- Combined Update & Cleanup Query
BEGIN;

-- Step 1 & 2: Build CTEs for duplicate mapping and order_items migration
WITH merged_book_data AS (
  SELECT 
    title,
    author_id,
    MIN(id) AS keep_id,
    SUM(stock_quantity) AS total_stock,
    STRING_AGG(DISTINCT TRIM(tag), ' ') AS aggregated_hashtags
  FROM books,
  LATERAL UNNEST(STRING_TO_ARRAY(hashtags, ' ')) AS tag
  WHERE TRIM(tag) != ''
  GROUP BY title, author_id
  HAVING COUNT(DISTINCT id) > 1
),
duplicate_books AS (
  SELECT b.id AS delete_id, m.keep_id
  FROM books b
  JOIN merged_book_data m 
    ON b.title = m.title 
   AND b.author_id = m.author_id
  WHERE b.id != m.keep_id
),
-- Step 3: Re-link order_items from duplicate IDs to primary keep_ids
update_orders AS (
  UPDATE order_items oi
  SET book_id = db.keep_id
  FROM duplicate_books db
  WHERE oi.book_id = db.delete_id
),
-- Step 4: Update the primary book records with combined stock and merged hashtags
update_books AS (
  UPDATE books b
  SET 
    stock_quantity = m.total_stock,
    hashtags = m.aggregated_hashtags
  FROM merged_book_data m
  WHERE b.id = m.keep_id
)
-- Step 5: Safely delete the duplicate books
DELETE FROM books b1
USING books b2
WHERE b1.id > b2.id
  AND b1.title = b2.title
  AND b1.author_id = b2.author_id;

COMMIT;
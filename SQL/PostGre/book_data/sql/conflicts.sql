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
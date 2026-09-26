BEGIN;

-- =============================================================================
-- 1. INSERT NEW AUTHORS (Skipped if already present in database)
-- =============================================================================
INSERT INTO authors (first_name, last_name, bio)
VALUES
  ('Chloe', 'Aridjis', 'Mexican-American novelist and writer.'),
  ('Emma', 'Cline', 'American novelist and short story writer.'),
  ('Makenna', 'Goodman', 'American author and editor.'),
  ('M. John', 'Harrison', 'English science fiction and fantasy author.'),
  ('Marlon', 'James', 'Jamaican novelist and Booker Prize winner.'),
  ('Luke', 'Kennard', 'British poet and novelist.'),
  ('Kenan', 'Orhan', 'Turkish-American author and short story writer.'),
  ('Rebecca', 'Perry', 'British poet and writer.'),
  ('Gwendoline', 'Riley', 'English novelist and academic.'),
  ('Elizabeth', 'Strout', 'Pulitzer Prize-winning American novelist.'),
  ('Douglas', 'Stuart', 'Scottish-American author and Booker Prize winner.'),
  ('Djamel', 'White', 'Contemporary novelist and writer.'),
  ('Missouri', 'Williams', 'British writer and editor.'),
  ('Tayari', 'Jones', 'American author and professor.'),
  ('Michael', 'Pollan', 'American author, journalist, and activist.'),
  ('Ann', 'Patchett', 'American author and bookstore owner.'),
  ('Beverly', 'Gage', 'American historian and professor.'),
  ('George', 'Saunders', 'American writer and university professor.'),
  ('Camille', 'Bordas', 'French author writing in English.'),
  ('Vincent', 'Yu', 'Contemporary writer and essayist.'),
  ('Roopika', 'Risam', 'Digital humanities scholar and author.'),
  ('Ben', 'Lerner', 'American poet, novelist, and essayist.'),
  ('Colson', 'Whitehead', 'Pulitzer Prize-winning American novelist.')
ON CONFLICT (first_name, last_name) 
DO UPDATE SET bio = EXCLUDED.bio 
WHERE authors.bio IS NULL OR authors.bio = '';

-- =============================================================================
-- 2. INSERT BOOKS
-- =============================================================================
INSERT INTO books (title, isbn, author_id, genre_id, released_year, price, stock_quantity, pages, hashtags)
VALUES
  -- ---------------------------------------------------------------------------
  -- BOOKER PRIZE LIST
  -- ---------------------------------------------------------------------------
  (
    'The Shadow Of The Object', '9781804228001',
    (SELECT id FROM authors WHERE first_name = 'Chloe' AND last_name = 'Aridjis' LIMIT 1),
    9, 2026, 22.00, 10, 240, '#bookerprize #literaryfiction #art #identity'
  ),
  (
    'Switzy', '9780593802001',
    (SELECT id FROM authors WHERE first_name = 'Emma' AND last_name = 'Cline' LIMIT 1),
    9, 2026, 24.50, 10, 288, '#bookerprize #literaryfiction #contemporary'
  ),
  (
    'Helen Of Nowhere', '9781804228018',
    (SELECT id FROM authors WHERE first_name = 'Makenna' AND last_name = 'Goodman' LIMIT 1),
    9, 2026, 21.00, 10, 220, '#bookerprize #novel #nature #isolation'
  ),
  (
    'The End Of Everything', '9781804228025',
    (SELECT id FROM authors WHERE first_name = 'M. John' AND last_name = 'Harrison' LIMIT 1),
    3, 2026, 23.00, 10, 310, '#bookerprize #speculative #fantasy #sci-fi'
  ),
  (
    'The Disappearers', '9780593803008',
    (SELECT id FROM authors WHERE first_name = 'Marlon' AND last_name = 'James' LIMIT 1),
    9, 2026, 28.00, 10, 416, '#bookerprize #historicalfiction #caribbean'
  ),
  (
    'Black Bag', '9781804228032',
    (SELECT id FROM authors WHERE first_name = 'Luke' AND last_name = 'Kennard' LIMIT 1),
    34, 2026, 19.99, 10, 256, '#bookerprize #thriller #satire #darkhumor'
  ),
  (
    'The Renovation', '9781804228049',
    (SELECT id FROM authors WHERE first_name = 'Kenan' AND last_name = 'Orhan' LIMIT 1),
    9, 2026, 22.50, 10, 272, '#bookerprize #familydrama #novel'
  ),
  (
    'May We Feed The King', '9781804228056',
    (SELECT id FROM authors WHERE first_name = 'Rebecca' AND last_name = 'Perry' LIMIT 1),
    37, 2026, 18.00, 10, 190, '#bookerprize #shortstories #fables'
  ),
  (
    'The Palm House', '9781804228063',
    (SELECT id FROM authors WHERE first_name = 'Gwendoline' AND last_name = 'Riley' LIMIT 1),
    9, 2026, 20.00, 10, 208, '#bookerprize #literaryfiction #relationships'
  ),
  (
    'The Things We Never Say', '9780593804005',
    (SELECT id FROM authors WHERE first_name = 'Elizabeth' AND last_name = 'Strout' LIMIT 1),
    9, 2026, 27.00, 10, 304, '#bookerprize #barackobamareading #smalltown #humanconnection'
  ),
  (
    'John Of John', '9780593805002',
    (SELECT id FROM authors WHERE first_name = 'Douglas' AND last_name = 'Stuart' LIMIT 1),
    9, 2026, 26.00, 10, 350, '#bookerprize #workingclass #scotland #drama'
  ),
  (
    'All Them Dogs', '9781804228070',
    (SELECT id FROM authors WHERE first_name = 'Djamel' AND last_name = 'White' LIMIT 1),
    9, 2026, 21.50, 10, 260, '#bookerprize #urban #literaryfiction'
  ),
  (
    'The Vivisectors', '9781804228087',
    (SELECT id FROM authors WHERE first_name = 'Missouri' AND last_name = 'Williams' LIMIT 1),
    9, 2026, 23.99, 10, 298, '#bookerprize #dystopian #philosophical'
  ),

  -- ---------------------------------------------------------------------------
  -- BARACK OBAMA READING LIST
  -- ---------------------------------------------------------------------------
  (
    'Kin', '9780593806009',
    (SELECT id FROM authors WHERE first_name = 'Tayari' AND last_name = 'Jones' LIMIT 1),
    9, 2026, 26.99, 10, 336, '#barackobamareading #family #southernfiction'
  ),
  (
    'A World Appears', '9780593807006',
    (SELECT id FROM authors WHERE first_name = 'Michael' AND last_name = 'Pollan' LIMIT 1),
    2, 2026, 28.00, 10, 352, '#barackobamareading #nonfiction #science #nature'
  ),
  (
    'Whistler', '9780593808003',
    (SELECT id FROM authors WHERE first_name = 'Ann' AND last_name = 'Patchett' LIMIT 1),
    9, 2026, 27.50, 10, 320, '#barackobamareading #literaryfiction #friendship'
  ),
  (
    'This Land Is Your Land', '9780593809000',
    (SELECT id FROM authors WHERE first_name = 'Beverly' AND last_name = 'Gage' LIMIT 1),
    2, 2026, 32.00, 10, 480, '#barackobamareading #history #americanhistory #politics'
  ),
  (
    'Vigil', '9780593810006',
    (SELECT id FROM authors WHERE first_name = 'George' AND last_name = 'Saunders' LIMIT 1),
    37, 2026, 22.00, 10, 240, '#barackobamareading #shortstories #satire #humanity'
  ),
  (
    'One Sun Only', '9780593811003',
    (SELECT id FROM authors WHERE first_name = 'Camille' AND last_name = 'Bordas' LIMIT 1),
    9, 2026, 24.00, 10, 272, '#barackobamareading #comingofage #contemporary'
  ),
  (
    'Seek Immediate Shelter', '9781804228094',
    (SELECT id FROM authors WHERE first_name = 'Vincent' AND last_name = 'Yu' LIMIT 1),
    36, 2026, 21.00, 10, 224, '#barackobamareading #essays #society #climate'
  ),
  (
    'Data Empire', '9781804228100',
    (SELECT id FROM authors WHERE first_name = 'Roopika' AND last_name = 'Risam' LIMIT 1),
    15, 2026, 29.50, 10, 310, '#barackobamareading #tech #digitalculture #society'
  ),
  (
    'Transcription', '9780593812000',
    (SELECT id FROM authors WHERE first_name = 'Ben' AND last_name = 'Lerner' LIMIT 1),
    9, 2026, 25.00, 10, 288, '#barackobamareading #literaryfiction #art #language'
  ),
  (
    'Cool Machine', '9780593813007',
    (SELECT id FROM authors WHERE first_name = 'Colson' AND last_name = 'Whitehead' LIMIT 1),
    9, 2026, 28.50, 10, 336, '#barackobamareading #historicalfiction #americanlit'
  )
ON CONFLICT (isbn) DO NOTHING;

COMMIT;
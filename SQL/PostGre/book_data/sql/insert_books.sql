BEGIN;

-- =============================================================================
-- 1. INSERT AUTHORS (Skipped if already in database)
-- =============================================================================
INSERT INTO authors (first_name, last_name, bio)
VALUES
  ('Anne-Laure', 'Le Cunff', 'Neuroscientist and founder of Ness Labs.'),
  ('Chris', 'Voss', 'Former FBI hostage negotiator and author.'),
  ('Roland', 'Allen', 'Author and publisher specializing in history and design.'),
  ('Eleanor', 'Dooks', 'Co-author and memoirist.'),
  ('George', 'Mumford', 'Mindfulness coach and sports performance expert.'),
  ('Michelle', 'Zauner', 'Musician (Japanese Breakfast) and bestselling author.'),
  ('Antoinette', 'Lattouf', 'Journalist, broadcaster, and author.'),
  ('Beck', 'Dorey-Stein', 'Former White House stenographer and author.'),
  ('Tharik', 'Hussain', 'Travel writer, journalist, and broadcaster.'),
  ('John', 'Baxter', 'Paris-based author and travel writer.'),
  ('Matt', 'Kepnes', 'Travel writer known as Nomadic Matt.'),
  ('Seth', 'Kugel', 'Travel journalist and former NYT columnist.'),
  ('Monisha', 'Rajesh', 'Travel journalist and author.'),
  ('Scott M.', 'Curran', 'Social impact strategist and lawyer.'),
  ('Dee', 'Salmin', 'Radio presenter, podcaster, and author.'),
  ('Hannah', 'Ferguson', 'Co-founder of Cheek Media Co. and writer.'),
  ('Simran', 'Kaur', 'Financial educator and founder of Girls That Invest.'),
  ('Chang-rae', 'Lee', 'Award-winning Korean-American novelist.'),
  ('Cal', 'Newport', 'Computer science professor and productivity author.'),
  ('Rachel', 'Barr', 'Neuroscientist and mental health advocate.'),
  ('Vanessa', 'Druskat', 'Organizational psychologist and researcher.'),
  ('Jennifer', 'Shahade', 'Chess grandmaster, poker player, and author.'),
  ('Susan MacKenty', 'Brady', 'Leadership expert and executive coach.'),
  ('Soetsu', 'Yanagi', 'Philosopher and founder of the Mingei movement.'),
  ('Emily', 'Hauser', 'Classicist and author.'),
  ('Emily', 'St. James', 'Cultural critic, journalist, and author.'),
  ('Salma', 'El-Wardany', 'Writer, presenter, and poet.'),
  ('Arthur C.', 'Brooks', 'Harvard professor, columnist, and author.'),
  ('Duraid', 'Jalili', 'Lecturer in defense studies and security analysis.'),
  ('Gil', 'Durán', 'Journalist and former editorial page editor.'),
  ('Nikita', 'Desai', 'Yoga instructor and researcher.'),
  ('Kazumasa', 'Hayami', 'Japanese novelist and award-winning author.'),
  ('Robert', 'Kanigel', 'Biographer and science writer.'),
  ('Sadhguru', 'Jaggi Vasudev', 'Yogi, mystic, and founder of Isha Foundation.'),
  ('Om', 'Swami', 'Monk, entrepreneur, and author.'),
  ('James', 'Nestor', 'Science journalist and author.'),
  ('Marcus', 'Aurelius', 'Roman Emperor and Stoic philosopher.'),
  ('René', 'Mauborgne', 'INSEAD professor and business strategist.'),
  ('Chiyo', 'Uno', 'Iconic Japanese author and kimono designer.'),
  ('Marie', 'Aubert', 'Norwegian author and short story writer.'),
  ('Banine', 'Daghestani', 'French-Azerbaijani memoirist and novelist.'),
  ('Francesca Maria', 'Benvenuto', 'Italian novelist and lawyer.'),
  ('Meg', 'Tanaka', 'Chef and cookbook author.'),
  ('Carl', 'Marci', 'Neuroscientist and doctor.'),
  ('Samantha', 'Harvey', 'Buker Prize-winning novelist.'),
  ('Nao-Cola', 'Yamazaki', 'Acclaimed Japanese novelist and essayist.')
ON CONFLICT DO NOTHING;

-- =============================================================================
-- 2. INSERT BOOKS (Checks for ISBN uniqueness; maps author & genre dynamically)
-- =============================================================================
INSERT INTO books (title, isbn, author_id, genre_id, released_year, price, stock_quantity, pages, hashtags)
VALUES
  (
    'Tiny Experiments', '9781804220011',
    (SELECT id FROM authors WHERE first_name = 'Anne-Laure' AND last_name = 'Le Cunff' LIMIT 1),
    10, 2025, 18.99, 10, 256, '#selfhelp #productivity #neuroscience'
  ),
  (
    'Never Split The Difference', '9780062872302',
    (SELECT id FROM authors WHERE first_name = 'Chris' AND last_name = 'Voss' LIMIT 1),
    20, 2016, 19.99, 10, 274, '#negotiation #communication #business'
  ),
  (
    'The Notebook: A History Of Thinking On Paper', '978Profile001',
    (SELECT id FROM authors WHERE first_name = 'Roland' AND last_name = 'Allen' LIMIT 1),
    2, 2023, 24.50, 10, 384, '#history #writing #stationery'
  ),
  (
    'Sea Legs: A Mother-Daughter Memoir Of Caring Wonder And Whales', '9781771648011',
    (SELECT id FROM authors WHERE first_name = 'Eleanor' AND last_name = 'Dooks' LIMIT 1),
    5, 2024, 21.00, 10, 312, '#memoir #motherhood #whales #nature'
  ),
  (
    'The Mindful Athlete', '9781101980538',
    (SELECT id FROM authors WHERE first_name = 'George' AND last_name = 'Mumford' LIMIT 1),
    29, 2015, 17.50, 10, 272, '#mindfulness #sports #performance'
  ),
  (
    'Crying In H Mart', '9780525657743',
    (SELECT id FROM authors WHERE first_name = 'Michelle' AND last_name = 'Zauner' LIMIT 1),
    5, 2021, 16.99, 10, 256, '#memoir #grief #food #korean'
  ),
  (
    'Women Who Win', '9781761044001',
    (SELECT id FROM authors WHERE first_name = 'Antoinette' AND last_name = 'Lattouf' LIMIT 1),
    18, 2022, 22.00, 10, 288, '#feminism #career #diversity'
  ),
  (
    'From The Corner Of The Oval Office', '9780735223707',
    (SELECT id FROM authors WHERE first_name = 'Beck' AND last_name = 'Dorey-Stein' LIMIT 1),
    5, 2018, 18.00, 10, 352, '#memoir #politics #whitehouse'
  ),
  (
    'Minarets In The Mountains: A Journey Into Muslim Europe', '9781784777524',
    (SELECT id FROM authors WHERE first_name = 'Tharik' AND last_name = 'Hussain' LIMIT 1),
    6, 2021, 19.95, 10, 320, '#travel #balkans #islamichistory'
  ),
  (
    'The Most Beautiful Walk In The World', '9780061803734',
    (SELECT id FROM authors WHERE first_name = 'John' AND last_name = 'Baxter' LIMIT 1),
    6, 2011, 16.00, 10, 304, '#paris #travel #walking'
  ),
  (
    'How To Travel The World On $75 A Day', '9780147516886',
    (SELECT id FROM authors WHERE first_name = 'Matt' AND last_name = 'Kepnes' LIMIT 1),
    6, 2019, 18.00, 10, 368, '#budgettravel #nomadicmatt #travel'
  ),
  (
    'Rediscovers Travel', '9781324002001',
    (SELECT id FROM authors WHERE first_name = 'Seth' AND last_name = 'Kugel' LIMIT 1),
    6, 2018, 17.95, 10, 288, '#travel #adventure #exploration'
  ),
  (
    'Around The World In 80 Trains', '9781472948519',
    (SELECT id FROM authors WHERE first_name = 'Monisha' AND last_name = 'Rajesh' LIMIT 1),
    6, 2019, 20.00, 10, 336, '#trains #travel #worldtour'
  ),
  (
    'Better Good: A Simple System For Creating Lasting Impact', '9781637741001',
    (SELECT id FROM authors WHERE first_name = 'Scott M.' AND last_name = 'Curran' LIMIT 1),
    2, 2023, 23.50, 10, 240, '#socialimpact #leadership #purpose'
  ),
  (
    'It''s Not Love Actually', '9781761180011',
    (SELECT id FROM authors WHERE first_name = 'Dee' AND last_name = 'Salmin' LIMIT 1),
    8, 2023, 19.99, 10, 320, '#romance #relationships #modernlove'
  ),
  (
    'Bite Back', '9781761048001',
    (SELECT id FROM authors WHERE first_name = 'Hannah' AND last_name = 'Ferguson' LIMIT 1),
    36, 2023, 21.00, 10, 272, '#essays #feminism #media'
  ),
  (
    'Girls That Invest', '9781119893201',
    (SELECT id FROM authors WHERE first_name = 'Simran' AND last_name = 'Kaur' LIMIT 1),
    18, 2022, 22.95, 10, 256, '#finance #investing #wealth'
  ),
  (
    'A Tender Age', '9780593298001',
    (SELECT id FROM authors WHERE first_name = 'Chang-rae' AND last_name = 'Lee' LIMIT 1),
    9, 2021, 26.00, 10, 336, '#literaryfiction #novel #comingofage'
  ),
  (
    'Deep Work', '9781455586691',
    (SELECT id FROM authors WHERE first_name = 'Cal' AND last_name = 'Newport' LIMIT 1),
    10, 2016, 28.00, 10, 304, '#productivity #focus #career'
  ),
  (
    'How To Make Your Brain Your Best Friend', '9781801290011',
    (SELECT id FROM authors WHERE first_name = 'Rachel' AND last_name = 'Barr' LIMIT 1),
    10, 2023, 18.50, 10, 240, '#neuroscience #mentalhealth #selfhelp'
  ),
  (
    'The Emotionally Intelligent Team', '9780787984001',
    (SELECT id FROM authors WHERE first_name = 'Vanessa' AND last_name = 'Druskat' LIMIT 1),
    20, 2006, 32.00, 10, 256, '#teams #eq #management'
  ),
  (
    'Thinking Sideways', '9781941200011',
    (SELECT id FROM authors WHERE first_name = 'Jennifer' AND last_name = 'Shahade' LIMIT 1),
    10, 2024, 21.95, 10, 280, '#strategy #chess #decisionmaking'
  ),
  (
    'All The Difference: Six Leadership Actions To Bridge Perspectives', '9781637743001',
    (SELECT id FROM authors WHERE first_name = 'Susan MacKenty' AND last_name = 'Brady' LIMIT 1),
    18, 2024, 27.99, 10, 256, '#leadership #teams #management'
  ),
  (
    'The Beauty Of Everyday Things', '9780241366356',
    (SELECT id FROM authors WHERE first_name = 'Soetsu' AND last_name = 'Yanagi' LIMIT 1),
    24, 2019, 16.00, 10, 352, '#craft #art #japan #design'
  ),
  (
    'Mythica: A New History Of Homer''s World Through The Women Written Out', '9781804221001',
    (SELECT id FROM authors WHERE first_name = 'Emily' AND last_name = 'Hauser' LIMIT 1),
    2, 2025, 25.00, 10, 320, '#mythology #history #women'
  ),
  (
    'Wood Work', '9781035400011',
    (SELECT id FROM authors WHERE first_name = 'Emily' AND last_name = 'St. James' LIMIT 1),
    36, 2024, 20.00, 10, 288, '#culture #essays #identity'
  ),
  (
    'These Impossible Things', '9780593489201',
    (SELECT id FROM authors WHERE first_name = 'Salma' AND last_name = 'El-Wardany' LIMIT 1),
    9, 2022, 27.00, 10, 352, '#fiction #friendship #sisterhood'
  ),
  (
    'The Happiness Files: Insights On Work And Life', '9780593540011',
    (SELECT id FROM authors WHERE first_name = 'Arthur C.' AND last_name = 'Brooks' LIMIT 1),
    10, 2024, 24.00, 10, 224, '#happiness #philosophy #work'
  ),
  (
    'Convergence: Climate Change And Geopolitical Futures', '9781804222001',
    (SELECT id FROM authors WHERE first_name = 'Duraid' AND last_name = 'Jalili' LIMIT 1),
    2, 2024, 35.00, 10, 304, '#geopolitics #climate #security'
  ),
  (
    'The Nerd Reich: Silicon Valley Fascism And The War On Democracy', '9781788160011',
    (SELECT id FROM authors WHERE first_name = 'Gil' AND last_name = 'Durán' LIMIT 1),
    15, 2025, 26.95, 10, 288, '#tech #politics #siliconvalley'
  ),
  (
    'A Beginner''s Guide To The Roots Of Yoga', '9781804223001',
    (SELECT id FROM authors WHERE first_name = 'Nikita' AND last_name = 'Desai' LIMIT 1),
    10, 2023, 19.99, 10, 224, '#yoga #wellness #mindfulness'
  ),
  (
    'How Can My Manager Be So Stupid?', '9781804224001',
    (SELECT id FROM authors WHERE first_name = 'Kazumasa' AND last_name = 'Hayami' LIMIT 1),
    9, 2024, 18.00, 10, 240, '#japanesefiction #satire #workplace'
  ),
  (
    'Uncovering Antioch: The Ancient City And Its Lost Treasures', '9780307278001',
    (SELECT id FROM authors WHERE first_name = 'Robert' AND last_name = 'Kanigel' LIMIT 1),
    24, 2024, 30.00, 10, 368, '#archaeology #history #art'
  ),
  (
    'Inner Engineering: A Yogi''s Guide To Joy', '9780143130444',
    (SELECT id FROM authors WHERE first_name = 'Sadhguru' AND last_name = 'Jaggi Vasudev' LIMIT 1),
    10, 2016, 17.00, 10, 288, '#yoga #spirituality #joy'
  ),
  (
    'Mind Full To Mindful: Zen Wisdom From A Monk''s Bowl', '9789353020011',
    (SELECT id FROM authors WHERE first_name = 'Om' AND last_name = 'Swami' LIMIT 1),
    13, 2018, 15.50, 10, 208, '#zen #mindfulness #philosophy'
  ),
  (
    'Breath: The New Science Of A Lost Art', '9780735213616',
    (SELECT id FROM authors WHERE first_name = 'James' AND last_name = 'Nestor' LIMIT 1),
    10, 2020, 28.00, 10, 304, '#health #breathing #science'
  ),
  (
    'Meditations', '9780812968255',
    (SELECT id FROM authors WHERE first_name = 'Marcus' AND last_name = 'Aurelius' LIMIT 1),
    13, 2002, 11.00, 10, 256, '#stoicism #philosophy #classics'
  ),
  (
    'Blue Ocean Strategy', '9781625274496',
    (SELECT id FROM authors WHERE first_name = 'René' AND last_name = 'Mauborgne' LIMIT 1),
    18, 2015, 32.00, 10, 304, '#strategy #business #innovation'
  ),
  (
    'The Story Of A Single Woman', '9780811230011',
    (SELECT id FROM authors WHERE first_name = 'Chiyo' AND last_name = 'Uno' LIMIT 1),
    9, 2022, 16.95, 10, 192, '#japanesefiction #classics #women'
  ),
  (
    'Grown Ups', '9781786078001',
    (SELECT id FROM authors WHERE first_name = 'Marie' AND last_name = 'Aubert' LIMIT 1),
    9, 2021, 15.00, 10, 160, '#norwegian #fiction #family'
  ),
  (
    'Days In The Caucasus', '9781782275001',
    (SELECT id FROM authors WHERE first_name = 'Banine' AND last_name = 'Daghestani' LIMIT 1),
    5, 2019, 17.95, 10, 256, '#memoir #caucasus #history'
  ),
  (
    'So People Know It''s Me', '9781804225001',
    (SELECT id FROM authors WHERE first_name = 'Francesca Maria' AND last_name = 'Benvenuto' LIMIT 1),
    9, 2024, 18.00, 10, 208, '#italianfiction #naples #youth'
  ),
  (
    'Osozai: Everyday Japanese Home Cooking', '9781804226001',
    (SELECT id FROM authors WHERE first_name = 'Meg' AND last_name = 'Tanaka' LIMIT 1),
    25, 2024, 29.95, 10, 224, '#cookbook #japanese #homecooking'
  ),
  (
    'Rewired: Protecting Your Brain In The Digital Age', '9780593300011',
    (SELECT id FROM authors WHERE first_name = 'Carl' AND last_name = 'Marci' LIMIT 1),
    15, 2022, 27.00, 10, 320, '#tech #neuroscience #brain'
  ),
  (
    'Orbital', '9780593801001',
    (SELECT id FROM authors WHERE first_name = 'Samantha' AND last_name = 'Harvey' LIMIT 1),
    9, 2023, 22.00, 10, 144, '#fiction #bookerprize #space'
  ),
  (
    'Beautiful Distance', '9781804227001',
    (SELECT id FROM authors WHERE first_name = 'Nao-Cola' AND last_name = 'Yamazaki' LIMIT 1),
    9, 2024, 16.50, 10, 180, '#japanesefiction #translated #novel'
  )
ON CONFLICT (isbn) DO NOTHING;

COMMIT;
-- insert into tables of database bookshop

INSERT INTO customers (first_name, last_name, email, joined_date)
VALUES 
('Søren', 'Bakke', 'soren.kitesurf@nordicnet.no', '2026-03-12 09:15:22.451233'),
('Emma', 'Whitlock', 'emma.wh.nomad@gmail.com', '2026-03-12 10:22:11.102344'),
('Lukas', 'Müller', 'l.mueller.design@web.de', '2026-03-12 11:05:44.882190'),
('Chloé', 'Lefebvre', 'chloe.tarifa@orange.fr', '2026-03-12 12:45:30.551002'),
('Jasper', 'van der Meer', 'jasper.vdmeer@ziggo.nl', '2026-03-12 14:10:05.112233'),
('Aria', 'Rossi', 'rossi.aria@libero.it', '2026-03-12 15:33:18.992831'),
('Oliver', 'Smith', 'olliver.smith.uk@outlook.com', '2026-03-12 16:55:40.441552'),
('Freja', 'Jensen', 'freja.j@danishmail.dk', '2026-03-13 08:20:12.662110'),
('Liam', 'O’Connor', 'liam.kite.tarifa@gmail.com', '2026-03-13 09:12:33.771223'),
('Anika', 'Sharma', 'anika.sharma.coder@gmail.com', '2026-03-13 10:45:01.332445'),
('Sebastian', 'Meyer', 's.meyer.yoga@gmx.de', '2026-03-13 11:20:55.112998'),
('Zoë', 'Williams', 'zoe.waves@icloud.com', '2026-03-13 13:05:44.221004'),
('Matteo', 'Bianchi', 'm.bianchi@proton.me', '2026-03-13 14:50:18.552113'),
('Sofia', 'Lindberg', 'sofia.swede@yahoo.se', '2026-03-13 16:22:30.991882'),
('Julian', 'Bennett', 'jules.bennett@me.com', '2026-03-14 07:15:10.442331'),
('Noa', 'Cohen', 'noa.cohen.tarifa@gmail.com', '2026-03-14 08:40:22.112665'),
('Klara', 'Nowak', 'klara.n.art@wp.pl', '2026-03-14 09:12:55.772331'),
('Finn', 'Gallagher', 'finn.g@irishabroad.ie', '2026-03-14 10:05:33.881220'),
('Yuki', 'Tanaka', 'yuki.tanaka@tokyomail.jp', '2026-03-14 11:22:44.552119'),
('Isabella', 'Costa', 'bella.costa@uol.com.br', '2026-03-14 12:45:11.992884');

select * from customers;

ALTER TABLE customers 
ADD COLUMN gender VARCHAR(20);

-- General Events June 2026 (Updated dates to avoid May and Sundays)
INSERT INTO events (name, event_date, location, description) VALUES 
('Martial Arts & Mindfulness with Jet Li', '2026-06-02 19:00:00', 'Main Gallery', 'A deep dive into the philosophy of martial arts and true freedom, inspired by Jet Li''s memoir "Beyond Life and Death".'),
('Singapore Noir: Crime Fiction Spotlight', '2026-06-03 20:00:00', 'The Reading Nook', 'Exploring the dark alleys of Singapore through modern crime fiction, featuring "Names Have Been Changed" by Yu-Mei Balasingamchow.'),
('The Nvidia Way: AI and Tech Evolution', '2026-06-04 18:30:00', 'The Tech Hub', 'A discussion on the rise of Nvidia and the future of artificial intelligence, based on the new release by Tae Kim.'),
('Vegan Chinese Kitchen Workshop', '2026-06-06 12:00:00', 'The Bookstore Kitchen', 'Learn to cook delicious plant-based Chinese dishes inspired by Yang Liu''s "Vegan Chinese Food".'),
('The NeXT Chapter: Steve Jobs in Exile', '2026-06-10 17:00:00', 'The Biography Corner', 'An exploration of the crucial years between Apple and NeXT that shaped a visionary leader, based on the new biography by Walter Isaacson.'),
('Traveler''s Meetup: Epic Bike Rides', '2026-06-13 11:00:00', 'The Travel Lounge', 'Join fellow cycling enthusiasts for stories of the most scenic bike routes across Europe, featuring Lonely Planet''s latest guide.'),
('Japanese Tea Ceremony Workshop', '2026-06-18 18:00:00', 'The Tea Room', 'An authentic introduction to selecting and brewing the perfect cup of Sencha and Matcha, inspired by Per Oscar Brekell''s guide.'),
('Inside the Box: Management Masterclass', '2026-06-19 19:30:00', 'The Business Center', 'Discover how constraints can drive creativity and improve organizational management, featuring the work of David Epstein.'),
('Otters and Why They Matter', '2026-06-23 15:00:00', 'Nature Study Hall', 'A fun and educational talk on the natural history of otters and their importance to our environment, based on Heide Island''s new book.'),
('The Infinity Machine: DeepMind & AI', '2026-06-24 19:00:00', 'The Tech Hub', 'Exploring the quest for superintelligence with Demis Hassabis and DeepMind, based on the book by Sebastian Mallaby.');

-- Reeses Book Club Tarifa Edition (Monthly Series)
INSERT INTO events (name, event_date, location, description) VALUES 
('Reeses Book Club Tarifa Edition - True Biz', '2026-07-21 20:00:00', 'the bookshop veranda', 'July selection: A story about the deaf community, family, and rebellion.'),
('Reeses Book Club Tarifa Edition - The Unwedding', '2026-08-18 20:00:00', 'the bookshop veranda', 'August selection: A gripping thriller set at a luxury resort.'),
('Reeses Book Club Tarifa Edition - The Island of Missing Trees', '2026-09-15 20:00:00', 'the bookshop veranda', 'September selection: A moving story of love, division, and memory in Cyprus.'),
('Reeses Book Club Tarifa Edition - Sankofa', '2026-10-20 20:00:00', 'the bookshop veranda', 'October selection: A woman''s journey to find her father and her own identity.'),
('Reeses Book Club Tarifa Edition - L.A. Weather', '2026-11-17 20:00:00', 'the bookshop veranda', 'November selection: A family drama set against the backdrop of California weather.'),
('Reeses Book Club Tarifa Edition - Such a Fun Age', '2026-12-15 20:00:00', 'the bookshop veranda', 'December selection: A striking story about race, privilege, and complicated relationships.');

-- Additional Seasonal Events 2026
INSERT INTO events (name, event_date, location, description) VALUES 
('Surf-side Eating: Summer Social', '2026-07-07 19:00:00', 'the bookshop garden', 'Relaxed recipes and coastal living discussion.'),
('Hula & Hawaiian Traditions', '2026-07-16 18:30:00', 'the bookshop veranda', 'Cultural evening inspired by the book "Hula" by Jasmin Iolani Hakes.'),
('Silicon Valley History: Brotopia', '2026-08-04 19:00:00', 'The Tech Hub', 'Discussing the history and culture of tech, based on "Brotopia" by Emily Chang.'),
('Japanese Magic Realism Coffee Night', '2026-09-08 19:00:00', 'Zen Garden Café', 'A deep dive into Japanese contemporary fiction.'),
('The Code: Silicon Valley Revolution', '2026-10-06 18:30:00', 'The Tech Hub', 'Exploring the digital revolution that reshaped the world.');

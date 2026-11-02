select * from auth_group;
select * from auth_group_permissions;
select * from auth_permission;
select * from auth_user;
select * from auth_user_groups;
select * from auth_user_user_permissions;
select * from core_customer order by id desc;
select * from core_expense order by id desc;
select * from core_inventory;
select * from core_lesson order by date;
select * from core_lesson_attendees order by id desc;
select * from core_package order by purchase_date desc;
select * from django_admin_log;
select * from django_content_type;
select * from django_migrations;
select * from django_session;

copy core_lesson_attendees (id, lesson_id, customer_id) FROM '/Users/ulrike_imac_air/projects/SQL_code/SQL/PostGre/yoga/data/lessens_attendence_2026_04_10.csv' DELIMITER ',' CSV HEADER;
select * from core_lesson where lesson_type = 'YOGA' and time = '18:00:00' order by date;
select * from core_lesson where lesson_type = 'MEDITATION' order by date;
select * from core_lesson_attendees where customer_id = 169;
select * from core_package where customer_id = 169;

select * from core_customer where name = 'Ava Dubois';
select * from core_customer where id = 3078;
select * from core_customer where country = 'Spain';
select * from core_customer where city = 'Tarifa';
select * from core_package order by remaining_lessons desc;

UPDATE core_customer
SET country = 'United Kingdom'
WHERE country = 'UK';

-- 2. CUSTOMER METRICS
-- ==========================================================
-- Total number of customers
SELECT COUNT(*) AS total_customers 
FROM core_customer;

-- New customers joined in the last month
SELECT COUNT(*) AS new_customers_last_month 
FROM core_customer 
WHERE created_at >= CURRENT_DATE - INTERVAL '1 month';

-- New customers joined in the last ... for dashboard
SELECT 
    COUNT(*) FILTER (WHERE created_at >= NOW() - INTERVAL '1 day') AS last_24h,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '7 days') AS last_week,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '1 month') AS last_month,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '3 months') AS last_quarter,
    COUNT(*) FILTER (WHERE created_at >= CURRENT_DATE - INTERVAL '1 year') AS last_year
FROM core_customer;

INSERT INTO core_lesson (date, time, max_students, min_students, is_cancelled, notes, lesson_type)
VALUES
('2026-03-06', '18:00:00', 20, 3, false, '', 'YOGA'),
('2026-03-12', '18:00:00', 20, 3, false, '', 'YOGA'),
('2026-03-21', '18:00:00', 20, 3, false, '', 'YOGA'),
('2026-04-11', '18:00:00', 20, 3, false, '', 'YOGA'),
('2026-04-25', '18:00:00', 20, 3, false, '', 'YOGA');

Insert into core_lesson_attendees (lesson_id, customer_id)
Values
(91, 1611),
(97, 1611),
(113, 1611),
(318, 1611),
(119, 1611),
(125, 1611),
(131, 1611),
(137, 1611),
(143, 1611),
(149, 1611);


Select * from core_customer where created_at >= NOW();

-- 3. Statistics
-- ==========================================================
-- Which days and which months have the most attendees - tables core_lesson_attendees and core_lesson
-- which packages are the most popular to book - table core_package
-- which packages are booked by locals and which by visitors? tables core_package and core_customer
-- difference numbers in attendence between morning courses and evening courses - tables core_lesson and core_lesson_attendees
-- who attendended more morning courses / evening courses - locals or visitors? - tables core_lesson, core_customers and core_lesson_attendees
-- how often per week do locals attend courses - tables core_lesson, core_lessons and core_lesson_attendees


-- SQL query to insert local customers from Tarifa, Spain
-- Table: core_customer

INSERT INTO core_customer (name, email, phone, city, country, customer_type, created_at)
VALUES
('Francisco Javier García', 'javier.garcia@example.es', '+34910000001', 'Madrid', 'Spain', 'VISITOR', NOW()),
('María Carmen Rodríguez', 'marmen.rodriguez@example.es', '+34930000002', 'Barcelona', 'Spain', 'VISITOR', NOW()),
('José Antonio Martínez', 'jose.martinez@example.es', '+34950000003', 'Seville', 'Spain', 'VISITOR', NOW()),
('Montserrat Puig', 'montserrat.puig@example.es', '+34930000004', 'Girona', 'Spain', 'VISITOR', NOW()),
('Jordi Molins', 'jordi.molins@example.es', '+34930000005', 'Lleida', 'Spain', 'VISITOR', NOW()),
('Alejandro Sanz', 'alejandro.sanz@example.es', '+34910000006', 'Madrid', 'Spain', 'VISITOR', NOW()),
('Lucía Fernández', 'lucia.fernandez@example.es', '+34960000007', 'Valencia', 'Spain', 'VISITOR', NOW()),
('Eneko Agirre', 'eneko.agirre@example.es', '+34940000086', 'Getxo', 'Spain', 'VISITOR', NOW());

INSERT INTO core_customer (name, email, phone, city, country, customer_type, created_at)
VALUES 
('Søren Bakke', 'soren.kitesurf@nordicnet.no', '', 'Tarifa', 'Spain', 'LOCAL', '2026-03-12 09:15:22.451233'),
('Emma Whitlock', 'emma.wh.nomad@gmail.com', '', 'Tarifa', 'Spain', 'LOCAL', '2026-03-12 10:22:11.102344'),
('Isabella Costa', 'bella.costa@uol.com.br', '', 'Tarifa', 'Spain', 'LOCAL', '2026-03-14 12:45:11.992884');

select * from core_customer where city = 'Tarifa';
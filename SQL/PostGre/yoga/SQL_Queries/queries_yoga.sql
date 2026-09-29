-- Statistics

-- Want me to turn these into a reusable SQL view or analytics dashboard function?

-- ==========================================================
-- Which days and which months have the most attendees - tables core_lesson_attendees and core_lesson
-- Most popular days of the week
SELECT 
    TO_CHAR(l.date, 'Day') AS day_of_week,
    COUNT(la.id) AS total_attendees
FROM core_lesson l
JOIN core_lesson_attendees la ON l.id = la.lesson_id
WHERE l.is_cancelled = FALSE
GROUP BY TO_CHAR(l.date, 'Day'), EXTRACT(DOW FROM l.date)
ORDER BY total_attendees DESC;

-- Most popular months
SELECT 
    TO_CHAR(l.date, 'Month') AS month_name,
    COUNT(la.id) AS total_attendees
FROM core_lesson l
JOIN core_lesson_attendees la ON l.id = la.lesson_id
WHERE l.is_cancelled = FALSE
GROUP BY TO_CHAR(l.date, 'Month'), EXTRACT(MONTH FROM l.date)
ORDER BY total_attendees DESC;

-- which packages are the most popular to book - table core_package
SELECT 
    package_type,
    COUNT(id) AS total_packages_sold,
    SUM(price_paid) AS total_revenue
FROM core_package
GROUP BY package_type
ORDER BY total_packages_sold DESC;
-- which packages are booked by locals and which by visitors? tables core_package and core_customer
SELECT 
    c.customer_type,
    p.package_type,
    COUNT(p.id) AS total_booked
FROM core_package p
JOIN core_customer c ON p.customer_id = c.id
GROUP BY c.customer_type, p.package_type
ORDER BY c.customer_type, total_booked DESC;

-- difference numbers in attendence between morning courses and evening courses - tables core_lesson and core_lesson_attendees
SELECT 
    CASE 
        WHEN l.time < '12:00:00' THEN 'Morning'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(la.id) AS total_attendees,
    ROUND(COUNT(la.id)::NUMERIC / COUNT(DISTINCT l.id), 2) AS avg_attendees_per_lesson
FROM core_lesson l
JOIN core_lesson_attendees la ON l.id = la.lesson_id
WHERE l.is_cancelled = FALSE
GROUP BY time_of_day;
-- who attendended more morning courses / evening courses - locals or visitors? - tables core_lesson, core_customers and core_lesson_attendees
SELECT 
    c.customer_type,
    CASE 
        WHEN l.time < '12:00:00' THEN 'Morning'
        ELSE 'Evening'
    END AS time_of_day,
    COUNT(la.id) AS attendance_count
FROM core_lesson_attendees la
JOIN core_lesson l ON la.lesson_id = l.id
JOIN core_customer c ON la.customer_id = c.id
WHERE l.is_cancelled = FALSE
GROUP BY c.customer_type, time_of_day
ORDER BY time_of_day, attendance_count DESC;

-- how often per week do locals attend courses - tables core_lesson, core_lessons and core_lesson_attendees
WITH local_weekly_attendance AS (
    SELECT 
        la.customer_id,
        DATE_TRUNC('week', l.date) AS lesson_week,
        COUNT(la.id) AS classes_attended
    FROM core_lesson_attendees la
    JOIN core_lesson l ON la.lesson_id = l.id
    JOIN core_customer c ON la.customer_id = c.id
    WHERE c.customer_type = 'local' -- adjust filter to match your customer_type value
      AND l.is_cancelled = FALSE
    GROUP BY la.customer_id, lesson_week
)
SELECT 
    ROUND(AVG(classes_attended), 2) AS avg_classes_per_active_week,
    MAX(classes_attended) AS max_classes_in_a_week
FROM local_weekly_attendance;

-- where do my costumers come from? create queries for cities, countries, total numbers of costumers per city/country, total amount of booked/attended classes per city/country
-- Customers per City & Country
SELECT 
    COALESCE(country, 'Unknown') AS country,
    COALESCE(city, 'Unknown') AS city,
    COUNT(id) AS total_customers
FROM core_customer
GROUP BY country, city
ORDER BY total_customers DESC;

-- Total Booked Packages and Attended Classes per City/Country
SELECT 
    COALESCE(c.country, 'Unknown') AS country,
    COALESCE(c.city, 'Unknown') AS city,
    COUNT(DISTINCT c.id) AS total_customers,
    COUNT(DISTINCT p.id) AS total_packages_purchased,
    COUNT(DISTINCT la.id) AS total_classes_attended
FROM core_customer c
LEFT JOIN core_package p ON c.id = p.customer_id
LEFT JOIN core_lesson_attendees la ON c.id = la.customer_id
GROUP BY c.country, c.city
ORDER BY total_classes_attended DESC;
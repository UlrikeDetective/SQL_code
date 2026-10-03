-- IMPROVED BOOKSHOP SCHEMA --

-- 1. Authors Table (Normalization)
CREATE TABLE authors (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    bio TEXT
);

-- 2. Genres Table
CREATE TABLE genres (
    id SERIAL PRIMARY KEY,
    name VARCHAR(50) UNIQUE NOT NULL
);

-- 3. Books Table (Updated)
CREATE TABLE books (
    id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    isbn VARCHAR(13) UNIQUE,
    author_id INT REFERENCES authors(id) ON DELETE SET NULL,
    genre_id INT REFERENCES genres(id) ON DELETE SET NULL,
    released_year INT,
    price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    stock_quantity INT DEFAULT 0,
    pages INT,
    hashtags TEXT,
    CHECK (price >= 0),
    CHECK (stock_quantity >= 0)
);

-- 4. Customers Table (Unique Email)
CREATE TABLE customers (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    joined_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. Orders Table (Header)
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00
);

-- 6. Order Items Table (Transactional Detail)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id) ON DELETE CASCADE,
    book_id INT REFERENCES books(id),
    quantity INT NOT NULL DEFAULT 1,
    unit_price DECIMAL(10,2) NOT NULL, -- Price at the time of sale
    CHECK (quantity > 0)
);

-- 7. Reviews Table (Social)
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    book_id INT REFERENCES books(id) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(book_id, customer_id) -- One review per customer per book
);

-- 8. Event Types Table (price / cost / capacity template per kind of event)
CREATE TABLE event_types (
    id              SERIAL PRIMARY KEY,
    name            VARCHAR(50)   NOT NULL UNIQUE,
    ticket_price    NUMERIC(10,2) NOT NULL DEFAULT 15.00,  -- gross, incl. IVA
    cost_per_person NUMERIC(10,2) NOT NULL DEFAULT 0.00,   -- ingredients, snacks, materials
    fixed_cost      NUMERIC(10,2) NOT NULL DEFAULT 0.00,   -- licence, DJ, guest speaker fee
    max_attendees   INT           NOT NULL,
    iva_rate        NUMERIC(4,3)  NOT NULL DEFAULT 0.100,  -- 10% reduced "cultural" IVA
    notes           TEXT,
    CHECK (max_attendees > 0),
    CHECK (ticket_price >= 0 AND cost_per_person >= 0 AND fixed_cost >= 0)
);

-- 9. Events Table (Marketing)
-- ticket_price / cost_per_person / fixed_cost / max_attendees are per-event
-- overrides: NULL means "inherit the value from event_types".
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    event_date TIMESTAMP NOT NULL,
    location VARCHAR(100),
    description TEXT,
    event_type_id   INT NOT NULL REFERENCES event_types(id),
    ticket_price    NUMERIC(10,2),
    cost_per_person NUMERIC(10,2),
    fixed_cost      NUMERIC(10,2),
    max_attendees   INT
);

CREATE INDEX idx_events_type ON events(event_type_id);

-- 10. Event Registrations (Many-to-Many)
CREATE TABLE event_registrations (
    event_id INT REFERENCES events(id) ON DELETE CASCADE,
    customer_id INT REFERENCES customers(id) ON DELETE CASCADE,
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (event_id, customer_id)
);

-- 11. Event Economics View
-- Resolves per-event overrides against the type defaults, counts attendees
-- and derives the money: profit = heads x (net ticket - cost/head) - fixed cost.
CREATE OR REPLACE VIEW event_economics AS
SELECT
    e.id, e.name, e.event_date, e.location, e.description, e.event_type_id,
    et.name                                        AS event_type,
    COALESCE(e.ticket_price,    et.ticket_price)    AS ticket_price,
    COALESCE(e.cost_per_person, et.cost_per_person) AS cost_per_person,
    COALESCE(e.fixed_cost,      et.fixed_cost)      AS fixed_cost,
    COALESCE(e.max_attendees,   et.max_attendees)   AS max_attendees,
    et.iva_rate,
    COALESCE(r.attendees, 0)                        AS attendees,
    COALESCE(e.max_attendees, et.max_attendees) - COALESCE(r.attendees, 0) AS spots_left,
    COALESCE(r.attendees, 0) * COALESCE(e.ticket_price, et.ticket_price) AS ticket_revenue,
    COALESCE(r.attendees, 0) * ROUND(COALESCE(e.ticket_price, et.ticket_price) / (1 + et.iva_rate), 2) AS net_revenue,
    COALESCE(r.attendees, 0) * COALESCE(e.cost_per_person, et.cost_per_person) AS variable_cost,
    COALESCE(r.attendees, 0) * (ROUND(COALESCE(e.ticket_price, et.ticket_price) / (1 + et.iva_rate), 2)
                                - COALESCE(e.cost_per_person, et.cost_per_person))
        - COALESCE(e.fixed_cost, et.fixed_cost)     AS event_profit
FROM events e
JOIN event_types et ON et.id = e.event_type_id
LEFT JOIN (
    SELECT event_id, COUNT(*) AS attendees FROM event_registrations GROUP BY event_id
) r ON r.event_id = e.id;

-- SEEDING EXAMPLE DATA --

INSERT INTO authors (first_name, last_name) VALUES 
('Jhumpa', 'Lahiri'),
('Neil', 'Gaiman'),
('Sally', 'Rooney');

INSERT INTO genres (name) VALUES 
('Fiction'), 
('Fantasy'), 
('Non-Fiction');

INSERT INTO books (title, author_id, genre_id, released_year, price, stock_quantity, pages, hashtags) VALUES 
('The Namesake', 1, 1, 2003, 19.99, 32, 291, '#fiction #classic #identity'),
('American Gods', 2, 2, 2001, 24.50, 12, 465, '#fantasy #mythology #adventure'),
('Intermezzo', 3, 1, 2025, 28.00, 12, 391, '#fiction #modern #rooney');

INSERT INTO customers (first_name, last_name, email) VALUES 
('Boy', 'George', 'george@gmail.com'),
('David', 'Bowie', 'david@gmail.com');

-- An order for David Bowie buying 2 books
INSERT INTO orders (customer_id, total_amount) VALUES (2, 47.99);

INSERT INTO order_items (order_id, book_id, quantity, unit_price) VALUES 
(1, 1, 1, 19.99),
(1, 3, 1, 28.00);

-- A Review
INSERT INTO reviews (book_id, customer_id, rating, comment) VALUES 
(3, 2, 5, 'Absolutely brilliant writing.');

-- A store event
INSERT INTO events (name, event_date, location) VALUES 
('Rooney Launch Party', '2025-10-15 18:00:00', 'Downtown Branch');

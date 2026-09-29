-- Customers Table
CREATE TABLE core_customer (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(254) UNIQUE NOT NULL,
    phone VARCHAR(20),
    customer_type VARCHAR(10),
    city VARCHAR(100),
    country VARCHAR(100),
    username VARCHAR(100) UNIQUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Lessons Table
CREATE TABLE core_lesson (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE NOT NULL,
    time TIME WITHOUT TIME ZONE NOT NULL,
    max_students INTEGER,
    min_students INTEGER,
    is_cancelled BOOLEAN DEFAULT FALSE NOT NULL,
    notes TEXT,
    lesson_type VARCHAR(20)
);

-- Lesson Attendees Table (Junction Table)
CREATE TABLE core_lesson_attendees (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    lesson_id BIGINT NOT NULL REFERENCES core_lesson(id) ON DELETE CASCADE,
    customer_id BIGINT NOT NULL REFERENCES core_customer(id) ON DELETE CASCADE,
    CONSTRAINT unique_lesson_customer UNIQUE (lesson_id, customer_id)
);

-- Customer Packages Table
CREATE TABLE core_package (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    customer_id BIGINT NOT NULL REFERENCES core_customer(id) ON DELETE CASCADE,
    total_lessons INTEGER NOT NULL,
    remaining_lessons INTEGER NOT NULL,
    purchase_date DATE DEFAULT CURRENT_DATE NOT NULL,
    price_paid NUMERIC(6, 2) NOT NULL,
    package_type VARCHAR(20) NOT NULL
);

-- Expense Table
CREATE TABLE core_expense (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    date DATE DEFAULT CURRENT_DATE NOT NULL,
    category VARCHAR(10) NOT NULL,
    amount NUMERIC(8, 2) NOT NULL,
    description TEXT
);

-- Inventory Table
CREATE TABLE core_inventory (
    id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    item_name VARCHAR(100) NOT NULL,
    purchase_date DATE DEFAULT CURRENT_DATE NOT NULL,
    quantity INTEGER NOT NULL DEFAULT 1,
    price_per_unit NUMERIC(6, 2) NOT NULL,
    expected_lifetime_years DOUBLE PRECISION
);

-- Foreign Key Indexes for Performance Optimization
CREATE INDEX idx_lesson_attendees_lesson ON core_lesson_attendees(lesson_id);
CREATE INDEX idx_lesson_attendees_customer ON core_lesson_attendees(customer_id);
CREATE INDEX idx_package_customer ON core_package(customer_id);


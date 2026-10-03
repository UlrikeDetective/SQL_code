-- ==========================================================
-- MIGRATION: per-type pricing, cost structure and capacity for events
-- ==========================================================
-- Before: events had no price, no cost and no attendee limit, so the
-- financial dashboard had to assume a flat 15 EUR ticket for everything.
-- After:  every event belongs to an event_type that carries the default
-- price / cost / capacity, and any single event can override those.
-- ==========================================================

BEGIN;

-- 1. The template: one row per kind of event ------------------------------
CREATE TABLE IF NOT EXISTS event_types (
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

-- Seeded at the current flat 15 EUR assumption so no financial figure moves
-- until the real prices are entered in /admin/financials.
INSERT INTO event_types (name, ticket_price, cost_per_person, fixed_cost, max_attendees, notes) VALUES
    ('Cooking',       15.00, 0.00, 0.00,  25, 'Ingredients included - put the ingredient cost in cost_per_person'),
    ('Book event',    15.00, 0.00, 0.00, 100, 'Book circles, talks, author nights, poetry'),
    ('Movie / Party', 15.00, 0.00, 0.00, 200, 'Screenings and socials - licence or DJ goes in fixed_cost')
ON CONFLICT (name) DO NOTHING;

-- 2. Hook events up to a type, with optional per-event overrides ----------
-- NULL in an override column means "use the event type's value".
ALTER TABLE events
    ADD COLUMN IF NOT EXISTS event_type_id   INT REFERENCES event_types(id),
    ADD COLUMN IF NOT EXISTS ticket_price    NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS cost_per_person NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS fixed_cost      NUMERIC(10,2),
    ADD COLUMN IF NOT EXISTS max_attendees   INT;

-- 3. Classify the existing 306 events by their series name ----------------
UPDATE events SET event_type_id = (SELECT id FROM event_types WHERE name = 'Cooking')
WHERE name ILIKE '%kitchen%'
   OR name ILIKE '%cook%'
   OR name ILIKE '%tea ceremony%'
   OR name ILIKE '%eating%';

UPDATE events SET event_type_id = (SELECT id FROM event_types WHERE name = 'Movie / Party')
WHERE event_type_id IS NULL
  AND (name ILIKE '%movie%'
    OR name ILIKE '%cinema%'
    OR name ILIKE '%party%'
    OR name ILIKE '%tv watching%'
    OR name ILIKE 'Social Network%');

UPDATE events SET event_type_id = (SELECT id FROM event_types WHERE name = 'Book event')
WHERE event_type_id IS NULL;

ALTER TABLE events ALTER COLUMN event_type_id SET NOT NULL;

-- 4. Keep history truthful: past events that already sold more seats than
--    their new type allows keep their real attendance as a per-event cap.
UPDATE events e
SET max_attendees = r.cnt
FROM (SELECT event_id, COUNT(*) AS cnt FROM event_registrations GROUP BY event_id) r,
     event_types et
WHERE r.event_id = e.id
  AND et.id = e.event_type_id
  AND r.cnt > et.max_attendees;

CREATE INDEX IF NOT EXISTS idx_events_type ON events(event_type_id);

-- 5. One place that resolves overrides, counts attendees and does the maths.
--    Profit = attendees x (net ticket - cost per head) - fixed cost.
CREATE OR REPLACE VIEW event_economics AS
SELECT
    e.id,
    e.name,
    e.event_date,
    e.location,
    e.description,
    e.event_type_id,
    et.name                                            AS event_type,
    COALESCE(e.ticket_price,    et.ticket_price)        AS ticket_price,
    COALESCE(e.cost_per_person, et.cost_per_person)     AS cost_per_person,
    COALESCE(e.fixed_cost,      et.fixed_cost)          AS fixed_cost,
    COALESCE(e.max_attendees,   et.max_attendees)       AS max_attendees,
    et.iva_rate,
    COALESCE(r.attendees, 0)                            AS attendees,
    COALESCE(e.max_attendees, et.max_attendees) - COALESCE(r.attendees, 0) AS spots_left,
    -- money
    COALESCE(r.attendees, 0) * COALESCE(e.ticket_price, et.ticket_price) AS ticket_revenue,
    COALESCE(r.attendees, 0) * ROUND(COALESCE(e.ticket_price, et.ticket_price) / (1 + et.iva_rate), 2) AS net_revenue,
    COALESCE(r.attendees, 0) * COALESCE(e.cost_per_person, et.cost_per_person) AS variable_cost,
    COALESCE(r.attendees, 0) * (ROUND(COALESCE(e.ticket_price, et.ticket_price) / (1 + et.iva_rate), 2)
                                - COALESCE(e.cost_per_person, et.cost_per_person))
        - COALESCE(e.fixed_cost, et.fixed_cost)         AS event_profit
FROM events e
JOIN event_types et ON et.id = e.event_type_id
LEFT JOIN (
    SELECT event_id, COUNT(*) AS attendees
    FROM event_registrations
    GROUP BY event_id
) r ON r.event_id = e.id;

COMMIT;

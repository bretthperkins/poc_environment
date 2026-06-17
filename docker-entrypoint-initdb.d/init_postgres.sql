-- ============================================================================
-- 1. DATABASE SCHEMA INITIALIZATION
-- ============================================================================

-- Ensure the UUID extension is enabled for high-scale primary keys
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Drop the table if it already exists to ensure a clean slate
DROP TABLE IF EXISTS customers CASCADE;

-- Create a scalable, generic customers table
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    company_name VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL
);

-- Index the email column for high-speed indexing and lookups
CREATE INDEX idx_customers_email ON customers(email);


-- ============================================================================
-- 2. AUTOMATED SEEDING SCRIPT (100 ROWS)
-- ============================================================================

INSERT INTO customers (first_name, last_name, email, company_name, is_active)
SELECT 
    -- Generates realistic distinct names using programmatic arrays
    (ARRAY['John', 'Jane', 'Michael', 'Emily', 'David', 'Sarah', 'James', 'Jessica', 'Robert', 'Lisa'])[mod(i, 10) + 1] AS first_name,
    (ARRAY['Smith', 'Johnson', 'Williams', 'Brown', 'Jones', 'Miller', 'Davis', 'Garcia', 'Rodriguez', 'Wilson'])[mod(i * 3, 10) + 1] AS last_name,
    
    -- Combines index value with domain structure to guarantee strict uniqueness
    'user_' || i || '@' || (ARRAY['enterprise.com', 'startup.io', 'techcorp.net', 'scale.dev'])[mod(i, 4) + 1] AS email,
    
    -- Generates corporate entities programmatically
    'Company ' || CHR(65 + mod(i, 26)) || ' LLC' AS company_name,
    
    -- Distributes active status dynamically (90% True, 10% False)
    CASE WHEN mod(i, 10) = 0 THEN FALSE ELSE TRUE END AS is_active
FROM generate_series(1, 100) AS i;


select * from public.customers;
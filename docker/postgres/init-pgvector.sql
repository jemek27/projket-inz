-- Create extensions
CREATE EXTENSION IF NOT EXISTS vector;

-- Create databases if they don't exist
SELECT 'CREATE DATABASE hdised_client_db' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'hdised_client_db')\gexec
SELECT 'CREATE DATABASE takerestaurant' WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = 'takerestaurant')\gexec

-- Connect to hdised_client_db and enable vector
\c hdised_client_db
CREATE EXTENSION IF NOT EXISTS vector;

-- Connect to takerestaurant database
\c takerestaurant
CREATE EXTENSION IF NOT EXISTS vector;

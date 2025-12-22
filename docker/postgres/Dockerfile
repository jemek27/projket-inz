# Use official pgvector image (PostgreSQL 16 with pgvector pre-installed)
FROM pgvector/pgvector:pg16

# Copy init script to enable pgvector and create databases
COPY init-pgvector.sql /docker-entrypoint-initdb.d/

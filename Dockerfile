# Dockerfile.postgres
FROM postgres

# Copy the initialization script
COPY init.sql /docker-entrypoint-initdb.d/

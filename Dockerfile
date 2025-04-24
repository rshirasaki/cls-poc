# Dockerfile.postgres
FROM postgres

# Copy the initialization script
COPY ./sqls /docker-entrypoint-initdb.d/

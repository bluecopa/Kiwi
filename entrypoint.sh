
#!/bin/bash
set -e

# Set port to 3000 for Railway
sed -i 's/listen 8080/listen 3000/g' /etc/nginx/conf.d/default.conf

# Handle database from Railway
if [ -n "$DATABASE_URL" ]; then
    # Extract database info from DATABASE_URL
    regex="postgres://([^:]+):([^@]+)@([^:]+):([^/]+)/(.+)"
    if [[ $DATABASE_URL =~ $regex ]]; then
        export POSTGRES_USER="${BASH_REMATCH[1]}"
        export POSTGRES_PASSWORD="${BASH_REMATCH[2]}"
        export POSTGRES_HOST="${BASH_REMATCH[3]}"
        export POSTGRES_PORT="${BASH_REMATCH[4]}"
        export POSTGRES_DB="${BASH_REMATCH[5]}"
    fi
fi

# Run the original entrypoint with our arguments
exec /entrypoint.sh "$@"
# Use the official Kiwi TCMS image
FROM docker.io/kiwitcms/kiwi:latest

# Copy our custom entrypoint script
COPY ./entrypoint.sh /entrypoint-railway.sh
RUN chmod +x /entrypoint-railway.sh

# Expose port 3000 for Railway
EXPOSE 3000

# Use our custom entrypoint
ENTRYPOINT ["/entrypoint-railway.sh"]
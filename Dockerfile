# Use a more accessible base image
FROM python:3.11-slim

# Install dependencies
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    nginx \
    postgresql-client \
    mariadb-client \
    gettext \
    sscg \
    tar \
    locales && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set locale
RUN sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Continue with the standard Kiwi TCMS installation
COPY ./requirements/ /Kiwi/requirements/
RUN pip install --no-cache-dir -r /Kiwi/requirements/postgres.txt

# Create necessary directories
RUN mkdir -p /Kiwi/ssl /var/run/nginx /var/log/nginx /var/log/kiwi /Kiwi/uploads

# Copy application code
COPY ./manage.py /Kiwi/
COPY ./etc/kiwitcms/ /Kiwi/etc/kiwitcms/
COPY ./tcms/ /Kiwi/tcms/
COPY ./templates/ /Kiwi/templates/
COPY ./static/ /Kiwi/static/

# Configure Nginx
COPY ./etc/nginx/nginx.conf /etc/nginx/
COPY ./etc/nginx/conf.d/default.conf /etc/nginx/conf.d/

# Set permissions
RUN chown -R 1001:1001 /Kiwi /var/run/nginx /var/log/nginx /var/log/kiwi

# Set the working directory
WORKDIR /Kiwi

# Update static files
RUN SECRET_KEY=temporary KIWI_DONT_ENFORCE_HTTPS="yes" python manage.py collectstatic --noinput

# Expose ports
EXPOSE 8080 8443

# Set entrypoint
COPY ./etc/docker/entrypoint.sh /
ENTRYPOINT ["/entrypoint.sh"]
CMD ["wsgi"]

# Set user
USER 1001
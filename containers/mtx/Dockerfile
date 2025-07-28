FROM alpine:latest

RUN apk add --no-cache \
    libstdc++ \
    python3 \
    py3-pip \
    supervisor \
    curl \
    ca-certificates \
    ffmpeg

# Download and install mediamtx v1.13.1-ffmpeg binary
RUN curl -L -o /tmp/mediamtx.tar.gz \
    https://github.com/bluenviron/mediamtx/releases/download/v1.13.1/mediamtx_v1.13.1_linux_amd64.tar.gz \
    && tar -xzf /tmp/mediamtx.tar.gz -C /tmp \
    && mv /tmp/mediamtx /usr/local/bin/mediamtx \
    && chmod +x /usr/local/bin/mediamtx \
    && rm /tmp/mediamtx.tar.gz

# Install streamlink
RUN pip install --no-cache-dir --break-system-packages streamlink

# Create necessary directories
RUN mkdir -p /var/log/supervisor /var/run /etc/supervisor/conf.d && \
    chmod 755 /var/log/supervisor /var/run /etc/supervisor/conf.d && \
    touch /var/log/supervisor/supervisord.log && \
    chmod 644 /var/log/supervisor/supervisord.log

CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
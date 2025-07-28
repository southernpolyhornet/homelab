setup:
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ffmpeg

# _generate-media-mtx-config:
#     export $(grep -v '^#' .env | xargs) && envsubst < config/template_media-mtx.yaml > config/mediamtx.yml

up:
    docker compose --env-file .env up -d

down:
    docker compose down

rebuild:
    docker compose --env-file .env up -d --build

# Logging functions
logs-mtx:
    docker logs mtx

logs-mtx-follow:
    docker logs -f mtx

logs-jellyfin:
    docker logs jellyfin

logs-jellyfin-follow:
    docker logs -f jellyfin

# MediaMTX specific logs
logs-mtx-supervisor:
    docker exec mtx cat /var/log/supervisor/supervisord.log

logs-mtx-server:
    docker exec mtx cat /var/log/supervisor/mediamtx.log

logs-mtx-reolink:
    docker exec mtx cat /var/log/supervisor/reolink_camera001.log

logs-mtx-streamlink:
    docker exec mtx cat /var/log/supervisor/streamlink_karaoke.log

# Follow specific logs
logs-mtx-server-follow:
    docker exec mtx tail -f /var/log/supervisor/mediamtx.log

logs-mtx-reolink-follow:
    docker exec mtx tail -f /var/log/supervisor/reolink_camera001.log

logs-mtx-streamlink-follow:
    docker exec mtx tail -f /var/log/supervisor/streamlink_karaoke.log

# All MediaMTX logs
logs-mtx-all:
    echo "=== MediaMTX Server Log ==="
    docker exec mtx cat /var/log/supervisor/mediamtx.log
    echo -e "\n=== Supervisor Log ==="
    docker exec mtx cat /var/log/supervisor/supervisord.log
    echo -e "\n=== Reolink Script Log ==="
    docker exec mtx cat /var/log/supervisor/reolink_camera001.log
    echo -e "\n=== Streamlink Script Log ==="
    docker exec mtx cat /var/log/supervisor/streamlink_karaoke.log

# Process status
status-mtx:
    docker exec mtx ps aux

status-mtx-processes:
    docker exec mtx ps aux | grep -E "(ffmpeg|streamlink|mediamtx)"

# Debug functions
debug-mtx-config:
    docker exec mtx cat /mediamtx.yml

debug-mtx-env:
    docker exec mtx env | grep -E "(RTSP|MTX|SC_)"

debug-mtx-network:
    docker exec mtx netstat -tlnp

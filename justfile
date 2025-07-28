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
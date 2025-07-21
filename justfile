setup:
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ffmpeg

_generate-media-mtx-config:
    export $(grep -v '^#' .env | xargs) && envsubst < config/template_media-mtx.yaml > config/mediamtx.yml

up-jellyfin:
    docker compose --env-file .env up -d jellyfin

down-jellyfin:
    docker compose down jellyfin

up-mediamtx:
    just _generate-media-mtx-config
    docker compose --env-file .env up -d mediamtx

down-mediamtx:
    docker compose down mediamtx

up:
    just _generate-media-mtx-config
    docker compose --env-file .env up -d

down:
    docker compose down

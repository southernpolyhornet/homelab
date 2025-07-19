setup:
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ffmpeg

up-jellyfin:
    docker compose up -d jellyfin --env-file .env

down-jellyfin:
    docker compose down jellyfin

up-mediamtx:
    docker compose up -d mediamtx --env-file .env

down-mediamtx:
    docker compose down mediamtx

up-all:
    docker compose up -d --env-file .env

down-all:
    docker compose down

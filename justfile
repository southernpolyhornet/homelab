setup:
    apt-get update && apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin ffmpeg

up-jellyfin:
    docker compose --env-file .env up -d jellyfin

down-jellyfin:
    docker compose down jellyfin

up-mediamtx:
    docker compose --env-file .env up -d mediamtx

down-mediamtx:
    docker compose down mediamtx

up-all:
    docker compose --env-file .env up -d

down-all:
    docker compose down

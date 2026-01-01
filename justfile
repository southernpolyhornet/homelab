# NixOS deployment commands

# Check flake syntax and configuration
check:
    cd nixos && nix flake check

# Deploy NixOS to a fresh machine using nixos-anywhere
# Copies age key for SOPS secrets during deployment
# Usage: just deploy neptune
deploy-nixos-anywhere machine:
    #!/usr/bin/env bash
    set -e
    cd nixos
    AGE_KEY_FILE="$HOME/.config/sops/age/keys.txt"
    if [ ! -f "$AGE_KEY_FILE" ]; then
        echo "Error: Age key not found at $AGE_KEY_FILE"
        echo "Generate one with: age-keygen -o $AGE_KEY_FILE"
        exit 1
    fi
    echo "Deploying NixOS to {{machine}}..."
    echo "Copying age key for SOPS secrets..."
    nix run github:nix-community/nixos-anywhere -- \
        --extra-files "$AGE_KEY_FILE=/etc/sops/age/keys.txt" \
        root@{{machine}} \
        --flake .#{{machine}}

# Rebuild existing NixOS system (equivalent to nixos-rebuild switch)
# Updates configuration on an already-installed system
# Usage: just rebuild saturn
rebuild machine:
    #!/usr/bin/env bash
    set -e
    cd nixos
    echo "Rebuilding {{machine}}..."
    nixos-rebuild switch --flake .#{{machine}} --target-host {{machine}} --use-remote-sudo --fast

# Sync secrets from plaintext secrets.json to secrets.nix files
# Usage: just sync-secrets
sync-secrets:
    nix-shell -p jq mkpasswd --run ./scripts/sync-secrets.sh

# NixOS deployment commands

# Check flake syntax and configuration
check:
    cd nixos && nix flake check

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

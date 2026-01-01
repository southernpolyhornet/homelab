#!/usr/bin/env bash
# Sync secrets from plaintext secrets.json to secrets.nix files
# Simple approach: generates plaintext Nix files (no SOPS)

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$REPO_ROOT"

SECRETS_FILE="secrets.json"

if [ ! -f "$SECRETS_FILE" ]; then
  echo "Error: $SECRETS_FILE not found in $REPO_ROOT"
  exit 1
fi

# Check for required tools
for cmd in jq mkpasswd; do
  if ! command -v "$cmd" &> /dev/null; then
    echo "Error: $cmd not found. Install with: nix profile add nixpkgs#$cmd"
    exit 1
  fi
done

echo "Reading secrets from $SECRETS_FILE..."

# Process machines
if jq -e '.nixos.machines' "$SECRETS_FILE" > /dev/null 2>&1; then
  echo "Processing machines..."
  jq -r '.nixos.machines | keys[]' "$SECRETS_FILE" | while IFS= read -r machine; do
    echo "  Processing machine: $machine"
    
    # Generate secrets.nix file
    cat > "nixos/machines/$machine/secrets.nix" <<'EOF'
# Machine-specific secrets for MACHINE_NAME
# This file is auto-generated from secrets.json
# DO NOT EDIT MANUALLY - run: just sync-secrets

{
EOF
    
    # Process tailscale_auth_key
    tailscale_key=$(jq -r ".nixos.machines[\"$machine\"].tailscale_auth_key // empty" "$SECRETS_FILE")
    if [ -n "$tailscale_key" ]; then
      echo "  services.tailscale.authKey = \"$tailscale_key\";" >> "nixos/machines/$machine/secrets.nix"
    fi
    
    # Process ssh_authorized_keys
    if jq -e ".nixos.machines[\"$machine\"].ssh_authorized_keys" "$SECRETS_FILE" > /dev/null 2>&1; then
      echo "  users.users.morgan.openssh.authorizedKeys.keys = [" >> "nixos/machines/$machine/secrets.nix"
      jq -r ".nixos.machines[\"$machine\"].ssh_authorized_keys[]" "$SECRETS_FILE" | while IFS= read -r key; do
        echo "    \"$key\"" >> "nixos/machines/$machine/secrets.nix"
      done
      echo "  ];" >> "nixos/machines/$machine/secrets.nix"
    fi
    
    echo "}" >> "nixos/machines/$machine/secrets.nix"
    
    # Replace MACHINE_NAME placeholder
    sed -i "s/MACHINE_NAME/$machine/g" "nixos/machines/$machine/secrets.nix"
    
    echo "    ✓ Generated: nixos/machines/$machine/secrets.nix"
  done
fi

# Process users
if jq -e '.nixos.users' "$SECRETS_FILE" > /dev/null 2>&1; then
  echo "Processing users..."
  jq -r '.nixos.users | keys[]' "$SECRETS_FILE" | while IFS= read -r user; do
    echo "  Processing user: $user"
    
    # Generate secrets.nix file
    cat > "nixos/users/$user/secrets.nix" <<'EOF'
# User-specific secrets for USER_NAME
# This file is auto-generated from secrets.json
# DO NOT EDIT MANUALLY - run: just sync-secrets

{
EOF
    
    # Hash password if present
    password=$(jq -r ".nixos.users[\"$user\"].password // empty" "$SECRETS_FILE")
    if [ -n "$password" ] && [ "$password" != "null" ]; then
      password_hash=$(mkpasswd -m sha-512 "$password")
      echo "  users.users.$user.hashedPassword = \"$password_hash\";" >> "nixos/users/$user/secrets.nix"
    fi
    
    # Handle nested objects (like adguard)
    if jq -e ".nixos.users[\"$user\"].adguard" "$SECRETS_FILE" > /dev/null 2>&1; then
      username=$(jq -r ".nixos.users[\"$user\"].adguard.username" "$SECRETS_FILE")
      password=$(jq -r ".nixos.users[\"$user\"].adguard.password" "$SECRETS_FILE")
      echo "  services.adguardhome.settings.users = [" >> "nixos/users/$user/secrets.nix"
      echo "    {" >> "nixos/users/$user/secrets.nix"
      echo "      name = \"$username\";" >> "nixos/users/$user/secrets.nix"
      echo "      password = \"$password\";" >> "nixos/users/$user/secrets.nix"
      echo "    }" >> "nixos/users/$user/secrets.nix"
      echo "  ];" >> "nixos/users/$user/secrets.nix"
    fi
    
    echo "}" >> "nixos/users/$user/secrets.nix"
    
    # Replace USER_NAME placeholder
    sed -i "s/USER_NAME/$user/g" "nixos/users/$user/secrets.nix"
    
    echo "    ✓ Generated: nixos/users/$user/secrets.nix"
  done
fi

echo ""
echo "✓ Secrets synced successfully!"
echo "  Generated secrets.nix files (these are tracked in git)"

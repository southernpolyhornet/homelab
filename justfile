# NixOS installer and deployment commands

# Check flake syntax and configuration
check:
    cd nixos && nix flake check

# Build installer kexec tarball for a machine
# Output: nixos/result/tarball/nixos-system-*.tar.gz
build-installer machine:
    #!/usr/bin/env bash
    cd nixos
    nix build .#installer-{{machine}}
    echo "Installer built at: nixos/result/tarball/nixos-system-*.tar.gz"

# Deploy NixOS to a machine using nixos-anywhere with custom installer
# The installer auto-connects to WiFi and enables SSH
# Usage: just deploy saturn morgan@jollyroger
deploy machine host:
    #!/usr/bin/env bash
    cd nixos
    
    # Build installer if not already built
    if [ ! -d "result/tarball" ]; then
        echo "Building installer..."
        nix build .#installer-{{machine}}
    fi
    
    KEXEC_TARBALL=$(find result/tarball -name "nixos-system-*.tar.gz" | head -n 1)
    if [ -z "$KEXEC_TARBALL" ]; then
        echo "Error: Kexec tarball not found. Building..."
        nix build .#installer-{{machine}}
        KEXEC_TARBALL=$(find result/tarball -name "nixos-system-*.tar.gz" | head -n 1)
    fi
    
    echo "Deploying {{machine}} to {{host}} using custom installer..."
    nix run github:nix-community/nixos-anywhere -- \
        -f .#{{machine}} \
        --kexec "$KEXEC_TARBALL" \
        --ssh-option IdentitiesOnly=yes \
        {{host}}

# Full workflow: build installer and deploy
# Usage: just install saturn morgan@jollyroger
install machine host:
    just build-installer {{machine}}
    just deploy {{machine}} {{host}}

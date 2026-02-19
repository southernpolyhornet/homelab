# NixOS deployment commands

_setup:
	#!/usr/bin/env bash
	set -euo pipefail
	if [ -z "${IN_NIX_SHELL:-}" ]; then
		exec nix develop ./nixos
	fi

_tmpdir:
	#!/usr/bin/env bash
	set -euo pipefail
	mkdir -p .tmp

check: _setup
	nix flake check ./nixos

deploy-nixos-anywhere machine user hostname key_file: _setup _tmpdir
	#!/usr/bin/env bash
	set -euo pipefail
	MACHINE="{{machine}}"
	USER="{{user}}"
	HOSTNAME="{{hostname}}"
	KEY_FILE="{{key_file}}"

	if [ ! -f "$KEY_FILE" ]; then
		echo "ERROR: key_file does not exist: $KEY_FILE" >&2
		exit 1
	fi

	# Staging dir that will be copied to / on the target
	EXTRA_DIR="$(mktemp -d -p .tmp nixos-anywhere.XXXXXX)"

	cleanup() {
		if [ "${KEEP_TMP:-0}" != "1" ]; then
			rm -rf "$EXTRA_DIR"
		else
			echo "KEEP_TMP=1 set; leaving staging dir: $EXTRA_DIR"
		fi
	}
	trap cleanup EXIT

	mkdir -p "$EXTRA_DIR/etc/sops/age"
	cp -f "$KEY_FILE" "$EXTRA_DIR/etc/sops/age/keys.txt"
	chmod 600 "$EXTRA_DIR/etc/sops/age/keys.txt"

	echo "Deploying NixOS $MACHINE to $HOSTNAME as $USER..."
	nix run github:nix-community/nixos-anywhere -- \
		--extra-files "$EXTRA_DIR" \
		--build-on local \
		"$USER@$HOSTNAME" \
		--flake "./nixos#$MACHINE"

rebuild machine target='' build='': _setup
	#!/usr/bin/env bash
	set -euo pipefail
	MACHINE="{{machine}}"
	TARGET_HOST="{{target}}"
	BUILD_HOST="{{build}}"
	
	if [ -z "$TARGET_HOST" ]; then
		TARGET_HOST="$MACHINE"
	fi
	if [ -z "$BUILD_HOST" ]; then
		BUILD_HOST="$MACHINE"
	fi
	
	echo "Rebuilding $MACHINE (target: $TARGET_HOST, build: $BUILD_HOST)..."
	nix run nixpkgs#nixos-rebuild -- switch --flake ./nixos#$MACHINE --target-host "$TARGET_HOST" --build-host "$BUILD_HOST" --sudo --no-reexec

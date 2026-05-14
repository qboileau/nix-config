{
  config,
  pkgs,
  lib,
  ...
}: {
  # GPG configuration with automatic key restoration from agenix secrets
  
  programs.gpg = {
    enable = true;
    settings = {
      keyid-format = "0xlong";
      with-colons = true;
      with-fingerprint = true;
    };
  };

  # Restore GPG keys from age-encrypted armored exports
  # This runs as the user during home-manager activation
  home.activation.restoreGpgKeys = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    GPG_HOME="${config.home.homeDirectory}/.gnupg"
    mkdir -p "$GPG_HOME"
    chmod 700 "$GPG_HOME"

    # Define paths to decrypted agenix secret files
    GPG_SECRET_KEYS="/run/agenix/gpg_secret_keys"
    GPG_PUBLIC_KEYS="/run/agenix/gpg_public_keys"
    GPG_OWNERTRUST="/run/agenix/gpg_ownertrust"

    # Import secret keys
    if [ -f "$GPG_SECRET_KEYS" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_SECRET_KEYS" || true
    fi

    # Import public keys
    if [ -f "$GPG_PUBLIC_KEYS" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import "$GPG_PUBLIC_KEYS" || true
    fi

    # Restore trust levels
    if [ -f "$GPG_OWNERTRUST" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import-ownertrust "$GPG_OWNERTRUST" || true
    fi
  '';
}

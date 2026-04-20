# Agenix secrets declaration
# Public keys used to encrypt secrets — safe to commit
#
# When to rekey (re-encrypt all .age files with updated recipients):
#   - After adding/removing a host key or changing publicKeys for any secret
#   - After rotating the master age key
#
# How to rekey:
#   make secrets-rekey
#   # or manually: cd secrets && nix run github:ryantm/agenix -- --rekey -i /var/lib/age/key.txt
let
  # Master age key (used for rekeying from any machine)
  master = "age1d2naq9lhxytel2m4m5mfqlkwyv5yp36798hekgc2nnc3tcn43u3q0rm5ps";

  # Host SSH public keys (from /etc/ssh/ssh_host_ed25519_key.pub)
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOVTpuB4XpKSysDwocjtYlMMo06fUO4FoMQxVQhtGSNa";
  framework = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJryB+et0QwCGwOFGqTbi7a4qsKXnmMQth/aRZNBCNhl";

  # All keys that should be able to decrypt
  # NOTE: add framework here once its real host key is set above
  allKeys = [ master desktop framework];
in {
  # --- SSH ---
  "ssh/pro_id_rsa.age".publicKeys = allKeys;
  "ssh/pro_id_rsa.pub.age".publicKeys = allKeys;
  "ssh/config.age".publicKeys = allKeys;

  # --- GPG (armored exports from gpg --export) ---
  "gpg/secret-keys.asc.age".publicKeys = allKeys;
  "gpg/public-keys.asc.age".publicKeys = allKeys;
  "gpg/ownertrust.txt.age".publicKeys = allKeys;

  # --- Git (shared across hosts) ---
  "git/personal.age".publicKeys = allKeys;

  # --- Git (per host) ---
  "git/desktop/work.age".publicKeys = [ master desktop ];
  "git/desktop/conduktor.age".publicKeys = [ master desktop ];
  "git/framework/work.age".publicKeys = [ master framework ];
  "git/framework/conduktor.age".publicKeys = [ master framework ];

  # --- Shell secrets (per host) ---
  "shell/desktop/work.bashrc.age".publicKeys = [ master desktop ];
  "shell/framework/work.bashrc.age".publicKeys = [ master framework ];
  "shell/framework/conduktor.bashrc.age".publicKeys = [ master framework ];

  # --- NetworkManager (per host) ---
  "network/desktop/connections.tar.age".publicKeys = [ master desktop ];
  "network/framework/connections.tar.age".publicKeys = [ master framework ];

  # --- Bluetooth (per host) ---
  "bluetooth/desktop/devices.tar.age".publicKeys = [ master desktop ];
  "bluetooth/framework/devices.tar.age".publicKeys = [ master framework ];
}

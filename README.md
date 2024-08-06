# nix-config

From template `github:misterio77/nix-starter-config#standard`.

## Usage 

### Update flake
```
nix flake update
```

### Update system 
```
sudo nixos-rebuild switch --flake .#hostname
```

### Update home
```
home-manager switch --flake .#username@hostname
```
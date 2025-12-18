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

### Query configuration

```
# Get hostname form current flake nixos configuration (replace #hostname)
nix eval .#nixosConfigurations.#hostname.config.networking.hostName
``` 


### Upgrade channel


1. Add new channel
```
sudo nix-channel --add https://channels.nixos.org/nixos-25.11 nixos
```

2. Then update input in flake and run
```
nix flake update
```

3. Test update
```
sudo nixos-rebuild test --upgrade --flake ".#${HOSTNAME}" --use-remote-sudo
``` 

4. Switch update
```
sudo nixos-rebuild switch --upgrade --flake ".#${HOSTNAME}" --use-remote-sudo -p update-25.11
``` 
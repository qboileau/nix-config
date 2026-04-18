{...} :
{
  # Background services and configurations
  # Git, cloud sync, and other service-related modules
  
  imports = [
    ./git.nix
    ./cloud-sync.nix
  ];
}

{...} :
{
  # Core modules - always enabled
  # Essential utilities required on all hosts
  
  imports = [
    ./system.nix
    ./network.nix
    ./shell-tools.nix
  ];
}

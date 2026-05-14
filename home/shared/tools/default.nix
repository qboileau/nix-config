{...} :
{
  # System utility tools with granular options
  # Hardware-specific and monitoring tools
  
  imports = [
    ./gnupg.nix
    ./monitoring.nix
    ./bluetooth.nix
    ./peripherals.nix
  ];
}

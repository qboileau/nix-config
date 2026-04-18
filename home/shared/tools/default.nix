{...} :
{
  # System utility tools with granular options
  # Hardware-specific and monitoring tools
  
  imports = [
    ./monitoring.nix
    ./bluetooth.nix
    ./peripherals.nix
  ];
}

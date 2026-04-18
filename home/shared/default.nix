# Home-manager shared modules
# Core modules are always enabled, others have granular options

{...} : {
  imports = [
    ./xdg.nix
    ./theme.nix
    
    # New organized structure
    ./core
    ./apps
    ./tools
    ./services
    
    # Existing organized modules
    ./shells
    ./dev
    ./editors
    ./gaming
  ];
}

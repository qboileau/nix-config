{...} :
{
  # GUI Applications with granular options
  # Choose which applications to install per host
  
  imports = [
    ./productivity.nix
    ./communication.nix
    ./security.nix
    ./media.nix
    ./files.nix
    ./browsers.nix
  ];
}

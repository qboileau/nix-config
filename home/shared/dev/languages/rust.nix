{pkgs, config, lib, ...} :
let
  cfg = config.dev.languages;
in {
  options = {
    dev.languages.rust = {
      enable = lib.mkEnableOption "Rust development tools";
    };
  };

  config = lib.mkIf cfg.rust.enable {
    home.packages = with pkgs; [ 
      rustup  # Run `rustup default stable` to setup rustc/cargo
    ];
  };
}

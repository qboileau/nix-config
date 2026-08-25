{lib, pkgs, ...} :
let
  fontPkgs = with pkgs; [
    nerd-fonts.symbols-only
    nerd-fonts.fira-code
    nerd-fonts.noto
    noto-fonts
    noto-fonts-color-emoji
    font-awesome
  ];
in {

  home.packages = fontPkgs;

  # Flatpak sandboxes only see system font dirs and ~/.local/share/fonts, never the
  # home-manager profile. Without these links a Flatpak asking for "Noto Sans" (from
  # gtk-font-name) gets a dangling path from its own stale cache and renders tofu.
  home.file = lib.listToAttrs (map
    (p: lib.nameValuePair ".local/share/fonts/${p.pname}" { source = "${p}/share/fonts"; })
    fontPkgs);

  fonts.fontconfig.enable = true;
  fonts.fontconfig.defaultFonts.serif = [
    "NotoSerif Nerd Font"
  ];
  fonts.fontconfig.defaultFonts.sansSerif = [
    "NotoSans Nerd Font"
  ];
  fonts.fontconfig.defaultFonts.monospace = [
    "FiraCode Nerd Font Mono"
    "NotoMono Nerd Font Mono"
  ];
  fonts.fontconfig.defaultFonts.emoji = [
    "FiraCode Nerd Font Mono"
    "Symbols Nerd Font Mono"
    "Noto Color Emoji"
  ];
}

# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  # Namespaced under pkgs.local to avoid future conflicts with nixpkgs
  additions = final: _prev: {
    local = import ../pkgs final;
  };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });

    ## Strip the `gtkconfig` kded plugin from kde-gtk-config.
    # kdePackages = prev.kdePackages // {
    #   kde-gtk-config = prev.kdePackages.kde-gtk-config.overrideAttrs (old:
    #   {  
    #     postInstall = (old.postInstall or "") + ''
    #       rm -f "$out/lib/qt-6/plugins/kf6/kded/gtkconfig.so"
    #     '';
    #   });
    # };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.stdenv.hostPlatform.system;
      config.allowUnfree = true;
    };
  };
}

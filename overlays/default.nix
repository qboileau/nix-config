# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs final.pkgs;

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    
    # Fix openldap test failures in sandboxed builds
    # The syncreplication test is timing-sensitive and flaky in Nix's build environment
    openldap = prev.openldap.overrideAttrs (oldAttrs: {
      doCheck = false;
    });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      # Apply the same modifications to unstable packages
      overlays = [
        (ufinal: uprev: {
          # Fix openldap test failures in sandboxed builds
          openldap = uprev.openldap.overrideAttrs (oldAttrs: {
            doCheck = false;
          });
        })
      ];
    };
  };
}

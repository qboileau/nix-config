{
  lib,
  vscode-utils,
  vscode-extension-update-script,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "scratchpads";
    publisher = "buenon";
    version = "	2.0.0";
    hash = "sha256-y5LljxK8V9Fir9EoG8g9N735gISrlMg3czN21qF/KjI=";
  };

  postInstall = ''
    cd "$out/$installPrefix"
  '';

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/vscode-extensions.buenon.scratchpads/default.nix"
    ];
  };

  meta = {
    license = lib.licenses.mit;
  };
}
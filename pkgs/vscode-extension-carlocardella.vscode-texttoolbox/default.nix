{
  lib,
  vscode-utils,
  vscode-extension-update-script,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "vscode-texttoolbox";
    publisher = "CarloCardella";
    version = "2.29.0";
    hash = "sha256-+gez2m0VtPTcE1TY76tUJaGwosgc2TQyC8gnQwMgUqY=";
  };

  postInstall = ''
    cd "$out/$installPrefix"
  '';

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/vscode-extensions.carlocardella.vscode-texttoolbox/default.nix"
    ];
  };

  meta = {
    license = lib.licenses.mit;
  };
}
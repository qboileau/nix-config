{
  lib,
  vscode-utils,
  vscode-extension-update-script,
}:

vscode-utils.buildVscodeMarketplaceExtension {
  mktplcRef = {
    name = "terraform";
    publisher = "4ops";
    version = "0.2.5";
    hash = "sha256-t5ULeB0jvkt9a1m3gA5Du0Kl1FI1ZncqyAQlXBwyyfE=";
  };

  postInstall = ''
    cd "$out/$installPrefix"
  '';

  passthru.updateScript = vscode-extension-update-script {
    extraArgs = [
      "--override-filename"
      "pkgs/vscode-extensions.4ops.terraform/default.nix"
    ];
  };

  meta = {
    license = lib.licenses.mit;
  };
}

{
  stdenv,
  callPackage,
  fetchurl,
  lib,
}:

let

  pname = "open-lens";
  version = "6.5.2-366";

  sources = {
    x86_64-linux = {
      url = "https://github.com/MuhammedKalkan/OpenLens/releases/download/v${version}/OpenLens-${version}.x86_64.AppImage";
      hash = "sha256-ZAltAS/U/xh4kCT7vQ+NHAzWV7z0uE5GMQICHKSdj8k=";
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.hostPlatform.system} or (throw "Unsupported system: ${stdenv.hostPlatform.system}")) url hash;
  };

  meta = with lib; {
    description = "Kubernetes IDE";
    homepage = "https://github.com/MuhammedKalkan/OpenLens";
    license = licenses.lens;
    platforms = builtins.attrNames sources;
  };

in
  callPackage ./linux.nix {
    inherit pname version src meta;
  }

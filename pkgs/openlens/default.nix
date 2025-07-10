
{
  stdenv,
  callPackage,
  fetchurl,
  lib,
}:

let

  pname = "openlens-desktop";
  version = "6.5.2-366";

  sources = {
    x86_64-linux = {
      url = "https://github.com/MuhammedKalkan/OpenLens/releases/download/v${version}/OpenLens-${version}.x86_64.AppImage";
      hash = "sha256-AbuEU5gOckVU+eDIFnomc7ryLq68ihuk3c0XosoJp74=";
    };
  };

  src = fetchurl {
    inherit (sources.${stdenv.system} or (throw "Unsupported system: ${stdenv.system}")) url hash;
  };

  meta = with lib; {
    description = "Kubernetes IDE";
    homepage = "https://github.com/MuhammedKalkan/OpenLens";
    license = licenses.lens;
    platforms = builtins.attrNames sources;
  };

in
  callPackage ./linux.nix {
    inherit
      pname
      version
      src
      meta
      ;
  }

{ lib, buildNpmPackage, fetchFromGitHub, stdenv, }:
buildNpmPackage (finalAttrs: rec {
  pname = "readme-generator";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "bitnami";
    repo = "readme-generator-for-helm";
    tag = "${finalAttrs.version}";
    hash = "sha256-25HF8L/SrsWtrhHNw1VDty/VLAnMwLHOaNmJDitTz3g=";
  };

  npmDepsHash = "sha256-8sPsfqEr9cj7kB+AtzH3hVkFrEdfci7gR2cFiwyHKvQ=";

  dontNpmBuild = true;

  meta = {
    description = "Auto generate READMEs for Helm Charts";
    homepage = "https://github.com/bitnami/readme-generator-for-helm";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ "qboileau" ];
  };
})
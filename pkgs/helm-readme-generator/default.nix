{ lib, buildNpmPackage, fetchFromGitHub, stdenv, }:
buildGoModule rec {
  pname = "readme-generator";
  version = "2.7.2";

  src = fetchFromGitHub {
    owner = "bitnami";
    repo = "readme-generator-for-helm";
    tag = "${finalAttrs.version}";
    hash = "sha256-0y6gacmhx2frd37b3h6c14ndabxp8daw7k8imsnwbbnjpzqcb4fv";
  };

  npmDepsHash = "sha256-8sPsfqEr9cj7kB+AtzH3hVkFrEdfci7gR2cFiwyHKvQ=";


  meta = {
    description = "Auto generate READMEs for Helm Charts";
    homepage = "https://github.com/bitnami/readme-generator-for-helm";
    license = lib.licenses.apache2;
    maintainers = with lib.maintainers; [ "qboileau" ];
  };
}
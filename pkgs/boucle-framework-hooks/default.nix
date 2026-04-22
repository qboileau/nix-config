{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  jq,
  python3,
  coreutils,
  diffutils,
  bc,
  gnugrep,
  findutils,
  bash,
}:

stdenv.mkDerivation {
  pname = "boucle-framework-hooks";
  version = "unstable-9d7090f";

  src = fetchFromGitHub {
    owner = "Bande-a-Bonnot";
    repo = "Boucle-framework";
    rev = "9d7090fbd715004fe462d7b49b0688c5201883a3";
    hash = "sha256-GHLqRjO40BZNJ+c/BXEOcrZq+MybDY2EJ+Ds6Gk2M4I=";
  };

  nativeBuildInputs = [ makeWrapper ];

  dontBuild = true;

  installPhase = let
    runtimePath = lib.makeBinPath [
      jq python3 coreutils diffutils bc gnugrep findutils bash
    ];
  in ''
    runHook preInstall

    # read-once hooks + CLI https://github.com/Bande-a-Bonnot/Boucle-framework/tree/main/tools/read-once
    mkdir -p $out/libexec/read-once
    cp tools/read-once/hook.sh $out/libexec/read-once/hook.sh
    cp tools/read-once/compact.sh $out/libexec/read-once/compact.sh
    cp tools/read-once/read-once $out/libexec/read-once/read-once
    chmod +x $out/libexec/read-once/{hook.sh,compact.sh,read-once}

    # git-safe hook https://github.com/Bande-a-Bonnot/Boucle-framework/tree/main/tools/git-safe
    mkdir -p $out/libexec/git-safe
    cp tools/git-safe/hook.sh $out/libexec/git-safe/hook.sh
    chmod +x $out/libexec/git-safe/hook.sh

    # Wrap all scripts with runtime dependencies
    for script in \
      $out/libexec/read-once/hook.sh \
      $out/libexec/read-once/compact.sh \
      $out/libexec/read-once/read-once \
      $out/libexec/git-safe/hook.sh; do
      wrapProgram "$script" --prefix PATH : "${runtimePath}"
    done

    # CLIs to bin
    mkdir -p $out/bin
    ln -s $out/libexec/read-once/read-once $out/bin/read-once

    runHook postInstall
  '';

  meta = {
    description = "Claude Code hooks from Boucle-framework (read-once, git-safe)";
    homepage = "https://github.com/Bande-a-Bonnot/Boucle-framework";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}

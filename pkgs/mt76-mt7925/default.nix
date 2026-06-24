# Out-of-tree mt76 driver from zbowling/mt7925.
#
# Replaces the in-tree mt76/mt792x/mt7921/mt7925 modules with a fork that
# carries fixes still pending upstream review: MLO/RTNL deadlocks, NULL
# pointer derefs, suspend/resume hangs. Upstream supports kernels 6.17+.
#
# Build via `config.boot.kernelPackages.callPackage` so `kernel` is bound to
# the active kernelPackages set. Drop this package once a stable kernel
# carries the backports (current target: next 7.x LTS).
#
# Hash refresh:
#   nix-prefetch-url --type sha256 https://github.com/zbowling/mt7925/releases/download/v${version}/mt76-mt7925-dkms-${version}.tar.gz
#   nix hash convert --to sri --hash-algo sha256 <output>
{
  stdenv,
  lib,
  fetchurl,
  kernel,
}:
stdenv.mkDerivation rec {
  pname = "mt76-mt7925";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/zbowling/mt7925/releases/download/v${version}/mt76-mt7925-dkms-${version}.tar.gz";
    hash = "sha256-ppsqag5IV7vM9xvDDOo/Amg2utEka4tncSrNq3xkzgQ=";
  };

  # Tarball layout: mt76-mt7925-dkms-<ver>/{src,dkms.conf,...}
  # The kernel module sources are under src/.
  setSourceRoot = ''
    sourceRoot=$(echo */src)
  '';

  hardeningDisable = ["pic" "format"];
  nativeBuildInputs = kernel.moduleBuildDependencies;

  buildPhase = ''
    runHook preBuild
    make -C ${kernel.dev}/lib/modules/${kernel.modDirVersion}/build \
      M=$PWD modules
    runHook postBuild
  '';

  # Install under updates/ so modprobe prefers these over the in-tree modules
  # without needing a blacklist.
  installPhase = ''
    runHook preInstall
    install -dm755 $out/lib/modules/${kernel.modDirVersion}/updates/mt76
    find . -name '*.ko' -exec install -Dm644 {} -t $out/lib/modules/${kernel.modDirVersion}/updates/mt76/ \;
    runHook postInstall
  '';

  meta = {
    description = "Patched MediaTek mt76/mt7925 driver (zbowling fork) — MLO/RTNL deadlock and suspend/resume fixes";
    homepage = "https://github.com/zbowling/mt7925";
    license = with lib.licenses; [isc gpl2Only];
    platforms = ["x86_64-linux" "aarch64-linux"];
    broken = kernel.kernelOlder "6.17";
  };
}

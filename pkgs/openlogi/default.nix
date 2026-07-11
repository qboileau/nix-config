{
  lib,
  stdenv,
  fetchurl,
  dpkg,
  autoPatchelfHook,
  makeWrapper,
  wayland,
  libxkbcommon,
  vulkan-loader,
  fontconfig,
  openssl,
  libGL,
  libusb1,
  udev,
}:

stdenv.mkDerivation rec {
  pname = "openlogi";
  version = "0.6.19";

  src = fetchurl {
    url = "https://github.com/AprilNEA/OpenLogi/releases/download/v${version}/openlogi-v${version}-linux-amd64.deb";
    hash = "sha256-heEq68pLxcmLewqqShXUNkxFxnsou8lrrvFtWau/LMQ=";
  };

  nativeBuildInputs = [
    dpkg
    autoPatchelfHook
    makeWrapper
  ];

  buildInputs = [
    stdenv.cc.cc.lib
    wayland
    libxkbcommon
    vulkan-loader
    fontconfig.lib
    openssl
    libGL
    libusb1
    udev
  ];

  unpackPhase = ''
    dpkg-deb --extract "$src" .
  '';

  installPhase = ''
    runHook preInstall
    mkdir -p "$out"
    cp -r usr/. "$out/"
    runHook postInstall
  '';

  # GPUI dlopen's wayland/GL/Vulkan at runtime; autoPatchelfHook only handles
  # static ELF NEEDED entries, so we must expose these via LD_LIBRARY_PATH.
  postFixup = ''
    for bin in "$out/bin/"*; do
      wrapProgram "$bin" \
        --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ wayland libGL vulkan-loader ]}
    done
  '';

  meta = with lib; {
    description = "Local-first companion for Logitech HID++ peripherals";
    homepage = "https://github.com/AprilNEA/OpenLogi";
    changelog = "https://github.com/AprilNEA/OpenLogi/releases/tag/v${version}";
    license = with lib.licenses; [ asl20 mit ];
    mainProgram = "openlogi";
    platforms = [ "x86_64-linux" ];
  };
}

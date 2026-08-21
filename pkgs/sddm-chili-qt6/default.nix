# Qt6 port of MarianArlt/sddm-chili (upstream is Qt5-only and unmaintained).
# Assets come from upstream; the QML in ./theme replaces the Qt5 sources.
{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  kdePackages,
  themeConfig ? { },
}: let
  defaults = {
    background = "assets/background.jpg";
    # Empty: Main.qml then follows the actual screen size instead of a fixed one.
    ScreenWidth = "";
    ScreenHeight = "";
    blur = true;
    recursiveBlurLoops = 4;
    recursiveBlurRadius = 15;
    PasswordFieldOutlined = false;
    PowerIconSize = "";
    FontPointSize = "";
    AvatarPixelSize = "";
    translationReboot = "";
    translationSuspend = "";
    translationPowerOff = "";
  };
  toValue = v:
    if builtins.isBool v
    then lib.boolToString v
    else toString v;
  settings = defaults // themeConfig;
  themeConf =
    lib.concatStringsSep "\n"
    (["[General]"] ++ lib.mapAttrsToList (k: v: "${k}=${toValue v}") settings);
in
  stdenvNoCC.mkDerivation {
    pname = "sddm-chili-qt6";
    version = "0.1.5-qt6";

    src = fetchFromGitHub {
      owner = "MarianArlt";
      repo = "sddm-chili";
      rev = "6516d50176c3b34df29003726ef9708813d06271";
      sha256 = "036fxsa7m8ymmp3p40z671z163y6fcsa9a641lrxdrw225ssq5f3";
    };

    dontWrapQtApps = true;

    # avoid .dev outputs propagation
    propagatedBuildInputs = [
      kdePackages.qt5compat.out
      kdePackages.qtsvg.out
      kdePackages.qtvirtualkeyboard.out
    ];

    installPhase = ''
      runHook preInstall

      theme=$out/share/sddm/themes/chili
      mkdir -p $theme
      cp -r assets $theme/
      cp AUTHORS LICENSE.md preview.jpg $theme/

      cp -r ${./theme}/. $theme/
      chmod -R u+w $theme

      printf '%s\n' ${lib.escapeShellArg themeConf} > $theme/theme.conf

      runHook postInstall
    '';

    meta = {
      description = "Qt6 port of the Chili login theme for SDDM";
      homepage = "https://github.com/MarianArlt/sddm-chili";
      license = lib.licenses.gpl3;
      platforms = lib.platforms.linux;
    };
  }

# sddm-chili-qt6

Qt6 port of [MarianArlt/sddm-chili](https://github.com/MarianArlt/sddm-chili).

Upstream targets Qt5 and is unmaintained. `nixpkgs.sddm-chili-theme` therefore
cannot render on a Qt6 greeter (`sddm-greeter-qt6`): SDDM silently falls back to
its built-in theme. This package ships ported QML that resolves under Qt6.

Assets (`assets/`, `preview.jpg`) come from the upstream tarball; only the QML
in `theme/` is replaced.

## What changed

| Qt5 | Qt6 |
| --- | --- |
| `QtGraphicalEffects 1.0` | `Qt5Compat.GraphicalEffects` (`RecursiveBlur`, `OpacityMask`) |
| `QtQuick.Controls 1.4` + `QtQuick.Controls.Styles 1.4` | `QtQuick.Controls` (Controls 2) |
| `TextFieldStyle` | `TextField.color` / `.placeholderTextColor` / `.background` |
| `ButtonStyle { label:, background: }` | `contentItem:` / `background:` |
| `Button.menu` / `ToolButton.menu` (removed) | child `Menu` + `onClicked: menu.popup()` |
| versioned imports | versionless |
| injected signal params | explicit `(a, b) => {}` |

`metadata.desktop` gains `QtVersion=6`.

## Upstream bugs fixed

All latent in the Qt5 original. Qt5 tolerated the layout violations; Qt6 does not.

- **Anchors on layout-managed items.** The virtual-keyboard `Loader` was a child of
  the main `ColumnLayout` yet set `anchors`, and both it and `loginFormStack` had
  their `y` driven by `PropertyChanges`. Qt6 reports *"Detected anchors on an item
  that is managed by a layout"* and the greeter crashes. The `Loader` is now a
  sibling of the layout, and the form is shifted with a `Translate` transform
  instead of `y`. `ActionButton` had the same problem — it sets `anchors` but is
  placed into a `RowLayout` via `actionItems`; it now uses `Layout.topMargin`.
- **Broken asset paths.** `iconSource`/`imageSource` are `property alias`es onto
  `Image.source`. A relative string assigned through an alias resolves against the
  *alias target's* file, so `"assets/reboot.svgz"` set in `Main.qml` resolved to
  `components/assets/reboot.svgz` and every power icon plus the wallpaper silently
  failed to load. Now wrapped in `Qt.resolvedUrl()` at the assignment site.
- `Main.qml` animated six transitions with `units.longDuration`, but `units` is a
  Plasma singleton that no SDDM theme provides and it was never defined here —
  a leftover from the Plasma Breeze theme chili was forked from. Replaced with a
  real `longDuration` property.
- `Main.qml` read `userListComponent.visibleBoundary`, never defined on
  `LoginForm`/`LoginFormLayout`, so the virtual-keyboard transition computed
  `Math.min(0, NaN)`. Defined in `LoginFormLayout.qml`.
- Font point sizes bound to properties that are still `0` on the first binding
  pass produced a burst of `QFont::setPointSizeF: Point size <= 0` warnings.
  Guarded with `Math.max(1, ...)`.

## Relation to sphaugh/sddm-chili

[sphaugh/sddm-chili](https://github.com/sphaugh/sddm-chili) is an independent Qt6
port of the same theme (Nix flake for a dev shell only, no package). It was found
after this port was written; the two agree on the Qt6 mechanics — imports,
Controls 2 rewrites, `QtVersion=6`, zero-font-size guards, signal parameters —
and on both asset-path bugs, which is decent mutual validation.

Where they differ:

- **`Instantiator` handlers.** They write `function onObjectAdded(index, object)`.
  That declares a method, not a signal handler — the property-binding form is
  required outside of `Connections`. Verified with a two-`Instantiator` test case
  under Qt 6.11: the binding form fires once per row, the function form never
  fires. So their session and keyboard-layout menus never populate, leaving
  `menu.count == 0` and the session picker permanently `visible: false`.
  This port uses `onObjectAdded: (index, object) => ...`.
- **Asset paths.** They compensate for the alias-resolution quirk by writing
  `"../assets/foo.svgz"` in `Main.qml` and `background=../assets/background.jpg`
  in `theme.conf`. That works, but leaks the quirk into user-facing config —
  their README still documents `background=assets/background.jpg`, which is now
  wrong. This port uses `Qt.resolvedUrl()` at the assignment site, so config
  paths stay relative to the theme root as documented.
- **Layout geometry.** They fixed the `Loader`'s anchors with `Layout.fillWidth`
  but kept `PropertyChanges { target: loginFormStack; y: ... }`, which still
  writes geometry on a layout-managed item. This port moves the `Loader` out of
  the layout and shifts the form with a `Translate`.
- **`units.longDuration` / `visibleBoundary`.** Still undefined in their fork.
  Fixed here.

Adopted from them: focusing the password field on startup
(`Component.onCompleted: passwordField.forceActiveFocus()` plus `focus: true` on
the `LoginForm`).

## Configuration

`themeConfig` keys map 1:1 onto `theme.conf` `[General]`:

```nix
pkgs.local.sddm-chili-qt6.override {
  themeConfig = {
    background = "${./wall.png}";
    blur = true;
    recursiveBlurRadius = 15;
    recursiveBlurLoops = 4;
    PasswordFieldOutlined = true;
    FontPointSize = 12;
    AvatarPixelSize = 140;
    PowerIconSize = 32;
    ScreenWidth = 3840;
    ScreenHeight = 2160;
    translationReboot = "Redémarrer";
    translationSuspend = "Veille";
    translationPowerOff = "Éteindre";
  };
}
```

Unset keys keep the defaults in `default.nix`.

### Blur

The wallpaper blur uses Qt6's `MultiEffect` (`QtQuick.Effects`, shipped in
qtdeclarative) rather than `Qt5Compat.GraphicalEffects.RecursiveBlur`.
`recursiveBlurRadius`/`recursiveBlurLoops` are kept as the tuning knobs for
continuity with upstream `theme.conf` and map onto `blurMax`/`blurMultiplier`.

Be aware that heavy blur on a smooth, dark gradient can show contour banding with
*any* blur implementation: blurring removes the grain and JPEG noise that were
dithering the 8-bit levels, leaving visible steps. If you see banding, try a
lower `recursiveBlurRadius`, or a wallpaper with more texture in the dark areas.

`ScreenWidth`/`ScreenHeight` are inherited from upstream but have no effect: the
greeter creates its view with `QQuickView::SizeRootObjectToView`, which
overwrites the root item's `width`/`height` and breaks those bindings. The theme
always fills the actual screen, and `generalFontSize` scales off its real height.

## Requirements

The greeter needs these on its QML import path, i.e. in
`services.displayManager.sddm.extraPackages`:

- `kdePackages.qt5compat` — `Qt5Compat.GraphicalEffects`
- `kdePackages.qtsvg` — `.svgz` assets
- `kdePackages.qtvirtualkeyboard` — `QtQuick.VirtualKeyboard`

The package itself must also be in `environment.systemPackages`, since SDDM
resolves `[Theme] Current=` against
`ThemeDir=/run/current-system/sw/share/sddm/themes`. `extraPackages` alone only
extends the QML import path.

## Verification

```sh
qmllint -I <qt5compat>/lib/qt-6/qml -I <qtvirtualkeyboard>/lib/qt-6/qml \
        -I <qtdeclarative>/lib/qt-6/qml -I <sddm>/lib/qt-6/qml \
        -I $theme $theme/Main.qml $theme/components/*.qml
```

Reports no errors and no unresolved imports. Remaining warnings are
unqualified access to greeter-injected context properties (`sddm`, `config`,
`userModel`, `screenModel`, `textConstants`), which qmllint cannot see, plus
comma-expression style warnings carried over verbatim from upstream.

For runtime checks, note that the greeter routes Qt logging away from stderr —
`QT_FORCE_STDERR_LOGGING=1` is required or you get a silent, empty log:

```sh
QT_QPA_PLATFORM=offscreen QML_DISABLE_DISK_CACHE=1 QT_FORCE_STDERR_LOGGING=1 \
  sddm-greeter-qt6 --test-mode --theme $theme
```

A clean run logs only `PopupList_QMLTYPE ... overrides a member of the base
object` (from SDDM's own `SddmComponents`) and `Socket error: QLocalSocket`
(expected without the daemon).

**You cannot log in from `--test-mode`, and there is no way to quit — kill the
window.** `GreeterApp::startup()` guards the daemon connection with
`!m_testing && !m_proxy->isConnected()`, so test mode runs with an unconnected
socket; `GreeterProxy::login()` still writes to it, producing one

```
Reading from ".../hyprland.desktop"
QIODevice::write (QLocalSocket): device not open
```

pair per attempt. Seeing those means the theme's login path works end to end and
only the IPC is missing. Test mode is for appearance only; to exercise a real
login, set the theme for real and log out.

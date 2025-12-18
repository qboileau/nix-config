# Gaming setup tips

## Env vars

- `MANGOHUD=1`
- `PROTON_ENABLE_WAYLAND=1`
- `PROTON_ENABLE_HDR=1`
- `ENABLE_HDR_WSI=1`
- `PROTON_USE_NTSYNC=1`
- `PROTON_USE_FSR4=1`
- `PROTON_FSR4_UPGRADE=1`
- `PROTON_FSR4_RDNA3_UPGRADE=1` : only for RDNA3 CG

## Steam run command

```
PROTON_ENABLE_WAYLAND=1 PROTON_ENABLE_HDR=1 ENABLE_HDR_WSI=1 PROTON_USE_NTSYNC=1 PROTON_USE_FSR4=1 PROTON_FSR4_UPGRADE=1 gamemoderun mangohud %command%
```

## Steam VR

### Fix binary permissions
```
sudo setcap CAP_SYS_NICE+ep ~/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/vrcompositor-launcher
```

### Run command
```
QT_QPA_PLATFORM=xcb %command%
```
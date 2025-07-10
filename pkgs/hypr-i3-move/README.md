# hypr-i3-move

Hyprland helper to navigate and move grouped windows in an i3-like fashion.  
Inspired by: https://github.com/hyprwm/Hyprland/discussions/2517#discussioncomment-10100000

Re-written in Go using Hyprland IPC for better performance.

## Usage

```
hypr-i3-move <focus|move> <direction>
```

- `<focus|move>`:  
  - `focus`: Change the active window within a group or move focus between windows.
  - `move`: Move the active window or the entire group in the specified direction.

- `<direction>`:  
  - One of `l`, `r`, `u`, `d` (left, right, up, down).

### Focus Mode

- If the active window is not grouped, moves focus in the given direction.
- If the active window is grouped:
  - If at the start/end of the group and moving further, moves focus out of the group.
  - Otherwise, cycles focus within the group using `changegroupactive`.

### Move Mode

- If the active window is not grouped, moves the window in the given direction.
- If the active window is grouped:
  - If at the start/end of the group and moving further, moves the group in that direction.
  - Otherwise, moves the window within the group using `movegroupwindow`.

## Example

Move focus right:
```
hypr-i3-move focus r
```

Move the current window or group left:
```
hypr-i3-move move l
```

## References

- Hyprland IPC: https://wiki.hypr.land/IPC/#how-to-use-socket2-with-bash
- Hyprctl IPC implementation: https://github.com/hyprwm/Hyprland/blob/main/hyprctl/main.cpp#L255
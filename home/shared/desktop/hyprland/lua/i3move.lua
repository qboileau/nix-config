-- i3-like directional focus/move for the dwindle layout: instead of jumping over a tabbed
-- group, stepping into one walks through its members and only leaves at the far edge.
--
-- In-process port of pkgs/hypr-i3-move (go). That binary drove Hyprland over the IPC socket
-- with `dispatch movefocus l`-style strings, which a lua config rejects: IPC dispatch became a
-- thin wrapper around hl.dispatch(<lua expr>) with no legacy-name path, and spawned processes
-- have stdout/stderr sent to /dev/null, so the failures were completely silent.
--
-- Deployed to ~/.config/hypr/i3move.lua and pulled in from the generated hyprland.lua as
-- `local i3move = require("i3move")`. Editor tooling works here: ~/.config/hypr/.luarc.json
-- (written by home-manager) points lua-ls at Hyprland's own stubs and declares `hl`.
--
-- Test a direction by hand against the running compositor:
--   hyprctl repl 'require("i3move").move("l")()'

---@alias Dir "l"|"r"|"u"|"d"

---@type table<Dir, string>
local DIRS = { l = "left", r = "right", u = "up", d = "down" }

-- l/u walk towards the start of a group, r/d towards the end.
---@type table<Dir, boolean>
local BACKWARD = { l = true, u = true }

---@param w HL.Window
---@return number, number
local function centre(w)
  return w.at.x + w.size.x / 2, w.at.y + w.size.y / 2
end

-- Nearest tiled window in `dir`: dominant-axis cone filter, then closest by centre distance.
---@param active HL.Window
---@param dir Dir
---@return HL.Window|nil
local function neighbour(active, dir)
  local ax, ay = centre(active)
  local best, bestDist

  for _, w in ipairs(hl.get_windows({ workspace = active.workspace.id, floating = false })) do
    if w.address ~= active.address and not w.hidden then
      local cx, cy = centre(w)
      local dx, dy = cx - ax, cy - ay

      local inDirection
      if dir == "l" then
        inDirection = dx < 0 and math.abs(dx) >= math.abs(dy)
      elseif dir == "r" then
        inDirection = dx > 0 and math.abs(dx) >= math.abs(dy)
      elseif dir == "u" then
        inDirection = dy < 0 and math.abs(dy) >= math.abs(dx)
      else
        inDirection = dy > 0 and math.abs(dy) >= math.abs(dx)
      end

      if inDirection then
        local dist = math.sqrt(dx * dx + dy * dy)
        if not bestDist or dist < bestDist then
          best, bestDist = w, dist
        end
      end
    end
  end

  return best
end

-- True when the window sits at the group edge we are heading out of, so the focus/move should
-- leave the group rather than step within it. `members` is a 1-indexed list of windows.
---@param w HL.Window
---@param dir Dir
---@return boolean
local function atGroupEdge(w, dir)
  local members = w.group.members
  local edge = BACKWARD[dir] and members[1] or members[#members]
  return edge ~= nil and edge.address == w.address
end

local M = {}

--- Returns a keybind callback: focus the neighbour in `dir`, walking groups member by member.
---@param dir Dir
---@return fun()
function M.focus(dir)
  return function()
    local w = hl.get_active_window()
    if not w then
      return
    end

    if not w.group or atGroupEdge(w, dir) then
      hl.dispatch(hl.dsp.focus({ direction = DIRS[dir] }))
    elseif BACKWARD[dir] then
      hl.dispatch(hl.dsp.group.prev())
    else
      hl.dispatch(hl.dsp.group.next())
    end
  end
end

--- Returns a keybind callback: move the active window in `dir`, merging into a neighbouring
--- group and reordering within its own group rather than jumping past either.
---@param dir Dir
---@return fun()
function M.move(dir)
  return function()
    local w = hl.get_active_window()
    if not w then
      return
    end

    if w.group then
      if atGroupEdge(w, dir) then
        hl.dispatch(hl.dsp.window.move({ direction = DIRS[dir], group_aware = true }))
      else
        hl.dispatch(hl.dsp.group.move_window({ forward = not BACKWARD[dir] }))
      end
      return
    end

    local n = neighbour(w, dir)
    if not n then
      return -- nothing that way, leave the layout alone
    end

    if n.group then
      -- merge into the neighbouring group
      hl.dispatch(hl.dsp.window.move({ direction = DIRS[dir], group_aware = true }))
    else
      -- plain neighbour: swap so the layout is preserved
      hl.dispatch(hl.dsp.window.swap({ direction = DIRS[dir] }))
    end
  end
end

return M

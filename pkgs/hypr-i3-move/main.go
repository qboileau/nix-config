package main

import (
    "encoding/json"
    "fmt"
    "io"
    "log"
    "math"
    "net"
    "os"
)

// ActiveWindow represents the structure of the JSON output from Hyprland IPC
type ActiveWindow struct {
    Address   string   `json:"address"`
    Grouped   []string `json:"grouped"`
    Workspace struct {
        ID int `json:"id"`
    } `json:"workspace"`
    At   [2]int `json:"at"`
    Size [2]int `json:"size"`
}

// Client represents a Hyprland client/window
type Client struct {
    Address   string   `json:"address"`
    Grouped   []string `json:"grouped"`
    Workspace struct {
        ID int `json:"id"`
    } `json:"workspace"`
    At       [2]int `json:"at"`
    Size     [2]int `json:"size"`
    Floating bool   `json:"floating"`
    Hidden   bool   `json:"hidden"`
}

func getSocketPath() string {
    xdgRuntimeDir := os.Getenv("XDG_RUNTIME_DIR")
    hyprlandInstanceSignature := os.Getenv("HYPRLAND_INSTANCE_SIGNATURE")

    if xdgRuntimeDir == "" || hyprlandInstanceSignature == "" {
        log.Fatal("Required environment variables XDG_RUNTIME_DIR or HYPRLAND_INSTANCE_SIGNATURE are not set.")
    }

    return fmt.Sprintf("%s/hypr/%s/.socket.sock", xdgRuntimeDir, hyprlandInstanceSignature)
}

func sendIPCCommand(socketPath, command string, out interface{}) error {
    conn, err := net.Dial("unix", socketPath)
    if err != nil {
        return fmt.Errorf("failed to connect to socket: %v", err)
    }
    defer conn.Close()

    if _, err := fmt.Fprintf(conn, "%s", command); err != nil {
        return fmt.Errorf("failed to send command: %v", err)
    }

    resp, err := io.ReadAll(conn)
    if err != nil {
        return fmt.Errorf("failed to read response: %v", err)
    }

    if out != nil {
        if err := json.Unmarshal(resp, out); err != nil {
            return fmt.Errorf("failed to parse response: %v\nRaw response: %s", err, string(resp))
        }
    }
    return nil
}

// center returns the center point of a window
func center(at [2]int, size [2]int) (float64, float64) {
    return float64(at[0]) + float64(size[0])/2.0, float64(at[1]) + float64(size[1])/2.0
}

// findNeighbor finds the nearest non-floating, non-hidden client in the given
// direction on the same workspace. It uses a directional cone filter and picks
// the closest candidate by Euclidean distance.
func findNeighbor(active ActiveWindow, clients []Client, direction string) *Client {
    ax, ay := center(active.At, active.Size)

    var best *Client
    bestDist := math.MaxFloat64

    for i := range clients {
        c := &clients[i]

        // Skip self (compare without leading "0x" prefix differences)
        if c.Address == active.Address {
            continue
        }
        // Same workspace only
        if c.Workspace.ID != active.Workspace.ID {
            continue
        }
        // Skip floating/hidden windows
        if c.Floating || c.Hidden {
            continue
        }

        cx, cy := center(c.At, c.Size)
        dx := cx - ax
        dy := cy - ay

        // Check that the candidate is in the correct direction.
        // We use a cone: the component in the desired direction must be
        // the dominant axis and have the correct sign.
        inDirection := false
        switch direction {
        case "l":
            inDirection = dx < 0 && math.Abs(dx) >= math.Abs(dy)
        case "r":
            inDirection = dx > 0 && math.Abs(dx) >= math.Abs(dy)
        case "u":
            inDirection = dy < 0 && math.Abs(dy) >= math.Abs(dx)
        case "d":
            inDirection = dy > 0 && math.Abs(dy) >= math.Abs(dx)
        }

        if !inDirection {
            continue
        }

        dist := math.Sqrt(dx*dx + dy*dy)
        if dist < bestDist {
            bestDist = dist
            best = c
        }
    }

    return best
}

func main() {
    if len(os.Args) != 3 {
        fmt.Println("Usage: hypr-i3-move <focus|move> <direction>")
        os.Exit(1)
    }

    mode := os.Args[1]
    direction := os.Args[2]
    socketPath := getSocketPath()

    var activeWindow ActiveWindow
    if err := sendIPCCommand(socketPath, "j/activewindow", &activeWindow); err != nil {
        log.Fatalf("Failed to get active window: %v", err)
    }

    send := func(cmd string) {
        if err := sendIPCCommand(socketPath, cmd, nil); err != nil {
            log.Printf("Failed to send command '%s': %v", cmd, err)
        }
    }

    grouped := activeWindow.Grouped
    addr := activeWindow.Address

    switch mode {
    case "focus":
        if len(grouped) == 0 {
            send(fmt.Sprintf("dispatch movefocus %s", direction))
            return
        }

        switch {
        case (direction == "l" || direction == "u") && addr == grouped[0]:
            send(fmt.Sprintf("dispatch movefocus %s", direction))
        case (direction == "r" || direction == "d") && addr == grouped[len(grouped)-1]:
            send(fmt.Sprintf("dispatch movefocus %s", direction))
        case direction == "l" || direction == "u":
            send("dispatch changegroupactive b")
        case direction == "r" || direction == "d":
            send("dispatch changegroupactive f")
        default:
            log.Printf("Unknown direction '%s'. Valid options are: l, r, u, d.", direction)
        }

    case "move":
        if len(grouped) == 0 {
            // Not in a group: check if the neighbor is in a group
            var clients []Client
            if err := sendIPCCommand(socketPath, "j/clients", &clients); err != nil {
                log.Printf("Failed to get clients: %v, falling back to swapwindow", err)
                send(fmt.Sprintf("dispatch swapwindow %s", direction))
                return
            }

            neighbor := findNeighbor(activeWindow, clients, direction)
            if neighbor == nil {
                // No neighbor in that direction — nothing to do
                return
            }

            if len(neighbor.Grouped) > 0 {
                // Neighbor is in a group — use movewindoworgroup to merge into it
                send(fmt.Sprintf("dispatch movewindoworgroup %s", direction))
            } else {
                // Neighbor is not in a group — use swapwindow to preserve layout
                send(fmt.Sprintf("dispatch swapwindow %s", direction))
            }
            return
        }

        // Already in a group
        switch {
        case (direction == "l" || direction == "u") && addr == grouped[0]:
            send(fmt.Sprintf("dispatch movewindoworgroup %s", direction))
        case (direction == "r" || direction == "d") && addr == grouped[len(grouped)-1]:
            send(fmt.Sprintf("dispatch movewindoworgroup %s", direction))
        case direction == "l" || direction == "u":
            send("dispatch movegroupwindow b")
        case direction == "r" || direction == "d":
            send("dispatch movegroupwindow f")
        default:
            log.Printf("Unknown direction '%s'. Valid options are: l, r, u, d.", direction)
        }

    default:
        fmt.Println("Invalid mode. Use 'focus' or 'move'.")
        os.Exit(1)
    }
}
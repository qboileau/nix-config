package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net"
	"os"
)

// ActiveWindow represents the structure of the JSON output from Hyprland IPC
type ActiveWindow struct {
	Address string   `json:"address"`
	Grouped []string `json:"grouped"`
}

// IPCRequest represents a generic IPC request structure
type IPCRequest struct {
	Command string `json:"command"`
}

// IPCResponse represents a generic IPC response structure
type IPCResponse struct {
	Success bool        `json:"success"`
	Error   string      `json:"error"`
	Data    interface{} `json:"data"`
}

func getSocketPath() string {
	xdgRuntimeDir := os.Getenv("XDG_RUNTIME_DIR")
	hyprlandInstanceSignature := os.Getenv("HYPRLAND_INSTANCE_SIGNATURE")

	if xdgRuntimeDir == "" || hyprlandInstanceSignature == "" {
		log.Fatal("Required environment variables XDG_RUNTIME_DIR or HYPRLAND_INSTANCE_SIGNATURE are not set.")
	}

	return fmt.Sprintf("%s/hypr/%s/.socket.sock", xdgRuntimeDir, hyprlandInstanceSignature)
}

func sendIPCCommand(socketPath, command string, response interface{}) error {
	conn, err := net.Dial("unix", socketPath)
	if err != nil {
		return fmt.Errorf("failed to connect to socket: %v", err)
	}
	defer conn.Close()

	ipcRequest := IPCRequest{Command: command}
	if err := json.NewEncoder(conn).Encode(ipcRequest); err != nil {
		return fmt.Errorf("failed to send command: %v", err)
	}

	if response != nil {
		if err := json.NewDecoder(conn).Decode(response); err != nil {
			return fmt.Errorf("failed to read response: %v", err)
		}
	}

	return nil
}

func main() {
	if len(os.Args) != 2 {
		fmt.Println("Usage: go-hyprctl <direction>")
		os.Exit(1)
	}

	direction := os.Args[1]
	socketPath := getSocketPath()

	var activeWindow ActiveWindow
	if err := sendIPCCommand(socketPath, "activewindow", &activeWindow); err != nil {
		log.Fatalf("Failed to get active window: %v", err)
	}

	if len(activeWindow.Grouped) == 0 {
		sendIPCCommand(socketPath, fmt.Sprintf("movefocus %s", direction), nil)
	} else if direction == "l" && activeWindow.Address == activeWindow.Grouped[0] {
		sendIPCCommand(socketPath, "movefocus l", nil)
	} else if direction == "l" {
		sendIPCCommand(socketPath, "changegroupactive b", nil)
	} else if direction == "r" && activeWindow.Address == activeWindow.Grouped[len(activeWindow.Grouped)-1] {
		sendIPCCommand(socketPath, "movefocus r", nil)
	} else {
		sendIPCCommand(socketPath, "changegroupactive f", nil)
	}
}

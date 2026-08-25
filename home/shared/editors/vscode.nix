{pkgs, config, lib, ...} :
let
  cfg = config.editors;
  claude-code-custom = pkgs.vscode-utils.buildVscodeMarketplaceExtension {
    mktplcRef = {
      name = "claude-code";
      publisher = "anthropic";
      version = "2.1.241"; # https://marketplace.visualstudio.com/items?itemName=anthropic.claude-code
      # Published per-platform since 2.1.89; without arch the fetch 404s.
      arch = "linux-x64";
      hash = "sha256-Gvn9Fv5VhzBzaFpuVir6VPFC0je0UAyh3LArY8MyjpA=";
    };
  };
in {
  options = {
    editors.vscode = {
      enable = lib.mkEnableOption "Visual Studio Code";
    };
  };

  config = lib.mkIf cfg.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.unstable.vscode;
    };
    

    home.packages = with pkgs; [ 
      nixfmt
      nil  # Nix Language Server
      nixd # Nix Language Server
    ];

  programs.vscode.profiles.default = {
    extensions = with pkgs.unstable; [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.mkhl.direnv
      vscode-extensions.davidanson.vscode-markdownlint
      vscode-extensions.bierner.markdown-mermaid
      vscode-extensions.github.vscode-pull-request-github
      vscode-extensions.github.vscode-github-actions
      vscode-extensions.github.copilot-chat
      vscode-extensions.hashicorp.terraform
      vscode-extensions.hashicorp.hcl
      vscode-extensions.golang.go
      vscode-extensions.scalameta.metals
      vscode-extensions.scala-lang.scala
      vscode-extensions.scala-lang.scala
      vscode-extensions.vscjava.vscode-gradle
      vscode-extensions.waderyan.gitblame
      vscode-extensions.donjayamanne.githistory
      vscode-extensions.humao.rest-client
      vscode-extensions.ms-vscode.hexeditor
      vscode-extensions.ms-vscode-remote.remote-ssh
      vscode-extensions.ms-vscode.remote-explorer
      vscode-extensions.ms-vscode-remote.remote-ssh-edit
      vscode-extensions.ms-vscode.makefile-tools
      vscode-extensions.ms-vscode-remote.remote-containers
      vscode-extensions.ms-kubernetes-tools.vscode-kubernetes-tools
      # vscode-extensions.rust-lang.rust-analyzer
      vscode-extensions.fill-labs.dependi
      vscode-extensions.vadimcn.vscode-lldb
      vscode-extensions.ms-azuretools.vscode-containers
      vscode-extensions.ms-python.python
    ] ++ [
      pkgs.local.vscode-extension-4ops-terraform
      pkgs.local."vscode-extension-carlocardella.vscode-texttoolbox"
      pkgs.local."vscode-extension-buenon.scratchpads"
      claude-code-custom
    ];
    keybindings = [
      {
        key = "ctrl+w"; # Disable close window on ctrl+w
        command = "-workbench.action.closeWindow";
        when = "!editorIsOpen && !multipleEditorGroups";
      }
      {
        key = "ctrl+w"; # Disable close editor tab on ctrl+w
        command = "-workbench.action.closeActiveEditor";
        when = "";
      }
      {
        key = "ctrl+q"; # Disable quit on ctrl+q
        command = "-workbench.action.quit";
        when = "";
      }
      {
        key = "shift+enter"; # Claude Code newline; /terminal-setup can't patch the read-only store symlink
        command = "workbench.action.terminal.sendSequence";
        args.text = builtins.fromJSON ''"\u001b\r"'';
        when = "terminalFocus";
      }
    ];
    userSettings = {
      "chat.viewSessions.orientation" = "stacked";
      "claudeCode.preferredLocation" = "panel";
      "excalidraw.image" = {
        "exportScale" = 1;
        "exportWithBackground" = true;
        "exportWithDarkMode" = false;
      };
      "excalidraw.language" = "en";
      "files.autoSave" = "onFocusChange";
      "files.watcherExclude"= {
        "**/.bloop" = true;
        "**/.metals" = true;
      };
      "git.confirmSync"= false;
      "git.replaceTagsWhenPull" = true;
      "github.copilot.chat.claudeCode.enabled" = true;
      "github.copilot.nextEditSuggestions.enabled" = true; 
      "metals.serverProperties" = [
        "-Xmx3G"
      ];  
      "metals.bloopJvmProperties" = [
        "-Xmx3G"
      ];
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = ["nixfmt"];
          };
        };
      };
      "terminal.explorerKind"= "both";
      "terminal.external.linuxExec"= "ghostty";
      "terminal.integrated.enableImages"= true;
      "workbench.editor.autoLockGroups" = {
        "imagePreview.previewEditor" = true;
      };
      "workbench.editorAssociations" = {
        "*.svg" = "editor.excalidraw";
      };
    };
  };
  };
}

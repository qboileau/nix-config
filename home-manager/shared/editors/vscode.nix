{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    };
    

  home.packages = with pkgs; [ 
    nixfmt-rfc-style
    nil # Nix Language Server
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
      vscode-extensions.waderyan.gitblame
      vscode-extensions.donjayamanne.githistory
      vscode-extensions.humao.rest-client
      vscode-extensions.ms-vscode.hexeditor
      # vscode-extensions.rust-lang.rust-analyzer
      vscode-extensions.fill-labs.dependi
      vscode-extensions.vadimcn.vscode-lldb
      vscode-extensions.ms-azuretools.vscode-containers
      vscode-extensions.ms-python.python
    ] ++ [
      pkgs.vscode-extension-4ops-terraform # custom package
      pkgs.vscode-extension-carlocardella.vscode-texttoolbox # custom package
      pkgs.vscode-extension-buenon.scratchpads # custom package
    ];
    keybindings = [
      # TODO
      # {
      #   key = "ctrl+c";
      #   command = "editor.action.clipboardCopyAction";
      #   when = "textInputFocus";
      # }
    ];
    userSettings = {
      # TODO
      "excalidraw.image" = {
        "exportScale" = 1;
        "exportWithBackground" = true;
        "exportWithDarkMode" = false;
      };
      "excalidraw.language" = "en";
      "files.autoSave" = "onFocusChange";
      "github.copilot.nextEditSuggestions.enabled" = true;
      "workbench.editor.autoLockGroups" = {
        "imagePreview.previewEditor" = true;
      };
      "workbench.editorAssociations" = {
        "*.svg" = "editor.excalidraw";
      };
      "files.watcherExclude"= {
        "**/.bloop" = true;
        "**/.metals" = true;
      };
      "git.confirmSync"= false;
      "nix.enableLanguageServer" = true;
      "nix.serverSettings" = {
        "nil" = {
          "formatting" = {
            "command" = ["nixfmt"];
          };
        };
      };
    };
  };

}

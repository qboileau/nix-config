{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
  };
  
  programs.vscode.profiles.default = {
    extensions = with pkgs; [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.davidanson.vscode-markdownlint
      vscode-extensions.github.vscode-pull-request-github
      vscode-extensions.hashicorp.terraform
      vscode-extensions.golang.go
      vscode-extensions.rust-lang.rust-analyzer
      vscode-extensions.fill-labs.dependi
      vscode-extensions.vadimcn.vscode-lldb
      vscode-extensions.github.vscode-github-actions
      unstable.vscode-extensions.ms-azuretools.vscode-containers
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
      "files.autoSave" = "onFocusChange";
      "excalidraw.language" = "en";
      "excalidraw.image" = {
        "exportScale" = 1;
        "exportWithBackground" = true;
        "exportWithDarkMode" = false;
      };
      "workbench.editor.autoLockGroups" = {
        "imagePreview.previewEditor" = true;
      };
      "workbench.editorAssociations" = {
        "*.svg" = "editor.excalidraw";
      };
    };

  };

}

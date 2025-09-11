{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
  };
  
  programs.vscode.profiles.default = {
    extensions = with pkgs.unstable; [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.davidanson.vscode-markdownlint
      vscode-extensions.github.vscode-pull-request-github
      vscode-extensions.github.vscode-github-actions
      vscode-extensions.github.copilot-chat
      vscode-extensions.hashicorp.terraform
      vscode-extension-4ops-terraform # custom package
      vscode-extensions.golang.go
      # vscode-extensions.rust-lang.rust-analyzer
      vscode-extensions.fill-labs.dependi
      vscode-extensions.vadimcn.vscode-lldb
      vscode-extensions.ms-azuretools.vscode-containers
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
      "git.confirmSync"= false;
    };
  };

}

{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
  };
  
  programs.vscode.profiles.default = {
    extensions = with pkgs; [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
      vscode-extensions.hashicorp.terraform
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

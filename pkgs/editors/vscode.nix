{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
    extensions = [
      vscode-extensions.bbenoist.nix
      vscode-extensions.jnoortheen.nix-ide
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
      "files.autoSave" = "on";
    };

  };

}
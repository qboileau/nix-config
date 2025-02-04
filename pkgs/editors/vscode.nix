{pkgs, ...} :
{

  programs.vscode = {
    enable = true;
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
      "files.autoSave" = "on";
    };

  };

}
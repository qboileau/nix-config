{pkgs, ...} :
let
  systemToolsInstructions = ''
    # System CLI Tool Replacements

    This system uses modern CLI replacements. When running terminal commands,
    use the actual binary names (not the aliases) to avoid issues:

    | Standard | Replacement | Binary    | Notes                        |
    |----------|-------------|-----------|------------------------------|
    | cat      | bat         | `bat`     | Syntax highlighting pager    |
    | grep     | ripgrep     | `rg`      | Faster, respects .gitignore  |
    | ls       | eza         | `eza`     | Git-aware, colored output    |
    | find     | fd          | `fd`      | Simpler syntax, respects .gitignore |
    | du/df    | duf         | `duf`     | Disk usage with nice UI      |

    ## Rules for terminal commands

    - Use `bat` instead of `cat` for reading files. If you need raw output without paging, use `bat --plain --paging=never` or call `$(which cat)` directly.
    - Use `rg` instead of `grep`. Note: `rg` flags differ from `grep` (e.g., `-E` is not supported, use `-e` for patterns, `--pcre2` for advanced regex).
    - Use `eza` instead of `ls`. Common flags: `--tree`, `--git`, `-lah`.
    - Use `fd` instead of `find`. Syntax: `fd <pattern>` instead of `find . -name <pattern>`.
    - Shell aliases are set: `cat=bat`, `grep=rg`, `ls=eza`, `df=duf`. Avoid piping alias-incompatible flags.
    - When you need the plain POSIX behavior (e.g., for scripting or parsing), use the full path: `$(which cat)`, `$(which grep)`, `$(which ls)`, `$(which find)`.
    - The system runs NixOS. Binaries are in `/run/current-system/sw/bin/` or `~/.nix-profile/bin/`, not `/usr/bin/`.
  '';
in {
  
  home.packages = with pkgs; [ 
    unstable.claude-code
    unstable.claude-monitor
    unstable.github-copilot-cli
    unstable.mistral-vibe
  ];

  # GitHub Copilot (VS Code) — user-level instructions, loaded in all workspaces
  xdg.configFile."Code/User/prompts/system-tools.instructions.md" = {
    text = ''
      ---
      applyTo: "**"
      description: "System CLI tool replacements: bat for cat, rg for grep, eza for ls, fd for find. Use when running terminal commands."
      ---
    '' + systemToolsInstructions;
  };

  # Claude Code — global instructions via ~/.claude/CLAUDE.md
  home.file.".claude/CLAUDE.md" = {
    text = systemToolsInstructions;
  };

}

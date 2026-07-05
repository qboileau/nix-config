{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
  boucleHooks = pkgs.boucle-framework-hooks;
  claudeSettings = {
    model = "opus";
    hooks = {
      PreToolUse = [
        {
          matcher = "Read";
          hooks = [{
            type = "command";
            command = "${boucleHooks}/libexec/read-once/hook.sh";
          }];
        }
        {
          matcher = "Bash";
          hooks = [{
            type = "command";
            command = "${boucleHooks}/libexec/git-safe/hook.sh";
          }];
        }
      ];
      PostCompact = [{
        matcher = "";
        hooks = [{
          type = "command";
          command = "${boucleHooks}/libexec/read-once/compact.sh";
        }];
      }];
    };
  };
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

    ## Nix development environments

    Always check for `flake.nix` or `shell.nix` in the project root before running terminal commands.
    - If `flake.nix` exists, wrap every command with: `nix develop --command bash -c '<command>'`
    - If `shell.nix` exists, wrap every command with: `nix-shell --run '<command>'`
    - Commands that are already prefixed with `nix develop` or `nix-shell` do not need wrapping.
    - A PreToolUse hook enforces this: bare commands will be blocked. Retry with the wrapped version from the hook output.
  '';
in {
  options = {
    dev.tools.ai = {
      enable = lib.mkEnableOption "AI development and productivity tools";
      amd = lib.mkEnableOption "Enable AMD GPU support for AI tools (e.g. Mistral Vibe, LLaMA.cpp)";
    };
  };

  config = lib.mkIf cfg.ai.enable {
    home.packages = with pkgs; [ 
      unstable.claude-monitor
      unstable.github-copilot-cli
      unstable.mistral-vibe
      unstable.llama-cpp 
      unstable.oterm
      unstable.lmstudio
      unstable.tgpt
      unstable.aichat
      unstable.python314Packages.transformers
      boucle-framework-hooks 
      # unstable.gpt4all
      # unstable.restate
    ] ++ lib.optional cfg.ai.amd [
      unstable.ollama-rocm
    ] ++ lib.optional (!cfg.ai.amd) [
      unstable.ollama
    ];

    

    # aichat configuration — use local Ollama as default backend
    xdg.configFile."aichat/config.yaml" = {
      text = ''
        model: ollama:qwen2.5-coder:32b
        clients:
          - type: ollama
            api_base: http://127.0.0.1:11434
            models:
              - name: qwen2.5-coder:32b
                max_input_tokens: 32768
              - name: llama3.3:70b
                max_input_tokens: 131072
              - name: llama3.2-vision:11b
                max_input_tokens: 131072
              - name: deepseek-coder-v2:16b
                max_input_tokens: 131072
      '';
    };

    # GitHub Copilot (VS Code) — user-level instructions, loaded in all workspaces
    xdg.configFile."Code/User/prompts/system-tools.instructions.md" = {
      text = ''
        ---
        applyTo: "**"
        description: "System CLI tool replacements: bat for cat, rg for grep, eza for ls, fd for find. Use when running terminal commands."
        ---
      '' + systemToolsInstructions;
    };


    programs.claude-code = {
      enable = true;
      package = pkgs.unstable.claude-code;
      settings = claudeSettings;
    };

    # Claude Code - global instructions via ~/.claude/CLAUDE.md
    home.file.".claude/CLAUDE.md" = {
      text = systemToolsInstructions;
    };

    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      rules = systemToolsInstructions;
      agents = {
        # https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/opencode.nix#L157
      };
      commands = {
        # https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/opencode.nix#L128
      };
      settings = {
        theme = "opencode";
        model = "anthropic/claude-sonnet-4-20250514";
        autoshare = false;
        autoupdate = true;
      };
    };
  };
}

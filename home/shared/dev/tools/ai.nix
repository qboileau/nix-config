{pkgs, config, lib, ...} :
let
  cfg = config.dev.tools;
  boucleHooks = pkgs.local.boucle-framework-hooks;
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
    - **`rg -r` is NOT recursive** — it means in-place replacement (like `sed`). `rg` is always recursive by default. Use `-r <replacement>` only when doing substitutions (e.g., `rg foo -r bar`).
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

    ## Code style principles

    - **YAGNI**: Don't add features, abstractions, or options that aren't needed right now.
    - **KISS**: Prefer the simplest solution. Avoid over-engineering.
    - **DRY**: Avoid duplication, but don't over-abstract for single-use cases.
    - **One-liners**: Prefer concise expressions over verbose equivalents when readability is not lost.
    - **Comments**: Code must be self-explanatory. Well-named functions, variables, types and small units need no narration. Write a comment only when it says what the code cannot: *why* a non-obvious choice was made, a workaround and the reason it exists, a link to a spec/issue/doc, or an invariant not visible locally. Never restate what the code does, never add section labels (`// loop over users`), never leave commented-out code, never write a docstring that just repeats the signature. If you feel a comment is needed to explain *what* happens, rename or extract instead. Keep comments short — one line when possible.
    - **Explicit over implicit**: Avoid magic values — use named constants.
    - **Pure functions**: Prefer side-effect-free functions. Isolate side effects at the edges.
    - **Fail loudly**: Don't swallow errors silently. Surface failures with actionable messages.
    - **No defensive bloat**: Skip null checks and guards for cases that can't happen — only validate at system boundaries.
    - **Types encode the rules**: Let the type system carry the business constraints so invalid states cannot be represented, instead of guarding against them at runtime. Prefer sum types (enums, unions, sealed/ADT) over boolean flags and stringly-typed values, dedicated types over raw `string`/`int`, non-empty/refined types over emptiness checks, required fields over optional-plus-null-check, immutable structures over mutation guards. Parse and validate once at the boundary, return a precise type, and let everything downstream trust it rather than re-checking. When the compiler can reject a bad state, no test or guard should be written for it.
    - **Hexagonal by default**: Keep the business domain free of infrastructure. Domain logic must not import HTTP, SQL, queues, files or SDK types; external concerns live in adapters behind an interface the domain owns. No need for a strict ports-and-adapters ceremony — what matters is that layers stay clearly separated so any connector can be swapped or faked, and the domain can be tested without booting anything.
    - **Bounded contexts**: Before adding to an existing module, ask which context the concept belongs to. Don't merge two contexts into one shared model just because they use the same word — each context keeps its own model, vocabulary and owner, and they talk through explicit translation at the boundary rather than by sharing entities. Prefer a little duplication across contexts over a coupled god-model.
    - **Don't assume**: When intent or context is unclear, verify by inspecting the code/files first, or ask for confirmation before proceeding.

    ### When principles collide

    - Scale first: YAGNI and KISS win on scripts and small single-purpose tools; hexagonal separation and bounded contexts win as soon as the code has more than one connector or more than one owner.
    - Bounded contexts beat DRY: duplication across contexts is correct, duplication within one context is not.
    - Types beat guards, guards beat silent failure. In dynamic languages, apply "types encode the rules" by validating once into a single boundary type (dataclass, schema, branded type) instead of re-checking downstream.
    - Readability beats concision: when a one-liner hides intent, name the parts.

    ## Keeping these principles applied

    These rules hold for the whole session, not just the first edit:
    - Every plan, todo list or task breakdown that touches code ends with a review step: "check the diff against the code style principles".
    - Before reporting any coding task as done, self-review your own diff and verify: no comment that restates the code, no commented-out code, no avoidable runtime guard for a state the type system could make unrepresentable, no abstraction with a single use.
    - Fix what the self-review finds before reporting completion — don't report it as a known caveat.
    - After a context compaction or a long session, re-read these principles before continuing to edit code.
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
      #unstable.mistral-vibe
      unstable.llama-cpp
      unstable.oterm
      unstable.lmstudio
      unstable.tgpt
      unstable.aichat
      unstable.graphify
      unstable.python314Packages.transformers
      local.boucle-framework-hooks
      # unstable.gpt4all
      # unstable.restate
    ] ++ lib.optionals cfg.ai.amd [
      unstable.ollama-rocm
    ] ++ lib.optionals (!cfg.ai.amd) [
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

    # `cclaude`: same Claude Code, but sandboxed in a container
    programs.cclaude = {
      enable = true;
      package = pkgs.unstable.claude-code;
    };

    # Claude Code - global instructions via ~/.claude/CLAUDE.md
    home.file.".claude/CLAUDE.md" = {
      text = systemToolsInstructions;
    };

    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      context = systemToolsInstructions;
      agents = {
        # https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/opencode.nix#L157
      };
      commands = {
        # https://github.com/nix-community/home-manager/blob/release-25.11/modules/programs/opencode.nix#L128
      };
      settings = {
        model = "anthropic/claude-sonnet-4-20250514";
        autoshare = false;
        autoupdate = true;
      };
      tui = {
        theme = "opencode";
      };
    };
  };
}

{pkgs, config, lib, inputs, ...} :
let
  cfg = config.dev.tools;
  llmAgents = inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system};
  boucleHooks = pkgs.local.boucle-framework-hooks;
  kubeLocalGuard = pkgs.writeShellApplication {
    name = "kube-local-guard";
    runtimeInputs = with pkgs; [ jq kubectl gnugrep gnused ];
    text = builtins.readFile ./kube-local-guard.sh;
  };
  # Listed under `ask` so a project's settings or a "don't ask again" click can't allow them.
  remoteInfraTools = [
    "aws" "gcloud" "gsutil" "bq" "az" "eksctl"
    "terraform" "tofu" "terragrunt" "pulumi"
    "tsh" "tctl" "kubectx" "kubens" "k9s"
    "ssh" "scp" "sftp" "rsync"
  ];
  # Unsandboxed so allow rules and the kube guard decide instead: local clusters live on the
  # host loopback, docker needs its socket, gh carries GITHUB_TOKEN, the JVM build tools can't
  # do Basic auth through the sandbox proxy (407), and nix's libgit2 chokes on the /dev/null
  # mask the sandbox puts on a missing .gitmodules, so every local flake eval fails inside it.
  unsandboxedTools = [ "kubectl" "helm" "flux" "gh" "docker" "nix" "nix-shell" "mvn" "./mvnw" "sbt" ];
  # Builds still run in the nix daemon's own sandbox; run/shell/develop/profile keep prompting.
  nixReadCommands = [
    "nix eval" "nix build" "nix log" "nix path-info" "nix search"
    "nix flake check" "nix flake metadata" "nix flake show"
  ];
  ghReadCommands = [
    "gh release view" "gh release list"
    "gh pr view" "gh pr list" "gh pr diff" "gh pr checks"
    "gh issue view" "gh issue list"
    "gh run view" "gh run list"
    "gh repo view" "gh search"
  ];
  bashRule = cmd: "Bash(${cmd} *)";
  claudeSettings = {
    model = "opus";
    sandbox = {
      enabled = true;
      autoAllowBashIfSandboxed = true;
      excludedCommands = map (tool: "${tool} *") unsandboxedTools;
      filesystem = {
        # Toolchain caches only: bin dirs would let sandboxed code plant binaries run later outside it.
        allowWrite = [ "~/.cache" "~/go/pkg" "~/.cargo/registry" "~/.cargo/git" "~/.npm" ];
        denyRead = [ "~/.ssh" "~/.gnupg" "~/.aws" "~/.config/gcloud" "~/.kube" "~/.tsh" "~/.docker" ];
      };
      # api.github.com is left out on purpose: GITHUB_TOKEN is in the environment.
      network.allowedDomains = [
        "github.com" "*.githubusercontent.com"
        "proxy.golang.org" "sum.golang.org"
        "registry.npmjs.org" "pypi.org" "files.pythonhosted.org"
        "index.crates.io" "static.crates.io"
      ];
    };
    permissions = {
      defaultMode = "acceptEdits";
      allow = map bashRule (ghReadCommands ++ nixReadCommands ++ [ "kubectl" "helm" "flux" ]);
      ask = map bashRule remoteInfraTools ++ [ "Bash(git push*)" ];
    };
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
          } {
            type = "command";
            command = lib.getExe kubeLocalGuard;
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
  claudeToolsInstructions = ''
    # Tools

    - Prefer the built-in Read, Grep and Glob tools over shell commands for reading and searching files.
  '';
  cliToolsInstructions = ''
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

    - Use `bat` instead of `cat` for reading files. If you need raw output without paging, use `bat --plain --paging=never` or `command cat`.
    - Use `rg` instead of `grep`. Note: `rg` flags differ from `grep` (e.g., `-E` is not supported, use `-e` for patterns, `--pcre2` for advanced regex).
    - **`rg -r` is NOT recursive** — it means in-place replacement (like `sed`). `rg` is always recursive by default. Use `-r <replacement>` only when doing substitutions (e.g., `rg foo -r bar`).
    - Use `eza` instead of `ls`. Common flags: `--tree`, `--git`, `-lah`.
    - Use `fd` instead of `find`. Syntax: `fd <pattern>` instead of `find . -name <pattern>`.
    - Shell aliases are set: `cat=bat`, `grep=rg`, `ls=eza`, `df=duf`. Avoid piping alias-incompatible flags.
    - When you need the plain POSIX behavior (e.g., for scripting or parsing), bypass the alias with the `command` builtin: `command cat`, `command grep`, `command ls`, `command find`.
  '';
  commonInstructions = ''

    ## Nix development environments

    - The system runs NixOS. Binaries are in `/run/current-system/sw/bin/` or `~/.nix-profile/bin/`, not `/usr/bin/`.
    - If `$IN_NIX_SHELL` is set, the project dev environment is already loaded (direnv): run commands directly, never wrap them.
    - Otherwise, run project toolchain commands (compilers, linters, test runners…) as `nix develop --command <cmd> <args>` when the project root has a `flake.nix`, or `nix-shell --run '<cmd>'` when it has a `shell.nix`. Never wrap them in `bash -c`.
    - System tools (`git`, `gh`, `jq`, `kubectl`, `rg`, `fd`…) are always on `PATH`: never wrap them.
    - Never run binaries you downloaded (e.g. into the scratchpad) or override the toolchain (e.g. `GOTOOLCHAIN`) without asking me first.

    ## Remote infrastructure

    - Never change remote or cloud infrastructure yourself (`aws`, `gcloud`, `terraform apply`, `kubectl`/`helm` against a non-local cluster, `ssh` to a server…). Give me the exact command, I run it and paste the output back.
    - Read-only inspection of remote infrastructure needs my approval: expect a prompt and say why you need it.
    - Local Kubernetes clusters (k3d, kind, minikube, docker-desktop…) can be used freely with `kubectl`, `helm` and `flux`, always passing the target context explicitly (`kubectl --context <ctx>`, `helm --kube-context <ctx>`, `flux --context <ctx>`): the current context may point to a remote cluster. List contexts with `kubectl config get-contexts`; never switch it with `use-context`.

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
  '';
in {
  options = {
    dev.tools.ai = {
      enable = lib.mkEnableOption "AI development and productivity tools";
      amd = lib.mkEnableOption "Enable AMD GPU support for AI tools (e.g. Mistral Vibe, LLaMA.cpp)";
      claudeCode.enable = lib.mkEnableOption "Claude Code CLI, its `cclaude` sandbox and global CLAUDE.md" // { default = true; };
      claudeDesktop.enable = lib.mkEnableOption "Claude Desktop app";
      orca.enable = lib.mkEnableOption "Orca, an IDE for running parallel coding agents";
    };
  };

  config = lib.mkIf cfg.ai.enable (lib.mkMerge [
  {
    home.packages = with pkgs; [
      unstable.claude-monitor
      unstable.github-copilot-cli
      #unstable.mistral-vibe
      unstable.llama-cpp
      oterm # unstable's depends on fastmcp-slim, marked broken there (2026-11)
      unstable.lmstudio
      unstable.tgpt
      # unstable.aichat
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
      '' + cliToolsInstructions + commonInstructions;
    };

    programs.opencode = {
      enable = true;
      package = pkgs.unstable.opencode;
      context = cliToolsInstructions + commonInstructions;
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
  }

  (lib.mkIf cfg.ai.claudeCode.enable {
    programs.claude-code = {
      enable = true;
      package = llmAgents.claude-code;
      settings = claudeSettings;
    };

    # `cclaude`: same Claude Code, but sandboxed in a container
    programs.cclaude = {
      enable = true;
      package = llmAgents.claude-code;
    };

    # Claude Code - global instructions via ~/.claude/CLAUDE.md
    home.file.".claude/CLAUDE.md" = {
      text = claudeToolsInstructions + commonInstructions;
    };
  })

  {
    home.packages =
      lib.optional cfg.ai.claudeDesktop.enable llmAgents.claude-desktop
      ++ lib.optional cfg.ai.orca.enable llmAgents.orca;
  }
  ]);
}

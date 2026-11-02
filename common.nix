{ pkgs, user, ... }:
{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    lazygit
    neovim
    tree
    terragrunt
    kubectx
    kubectl
    kubernetes-helm
    k9s
    openssh
    google-cloud-sdk # config stays in ~/.config/gcloud, so existing logins and projects keep working
    nerd-fonts.hack

    # Editor tooling for nvim (LSP, lint, format), provided here instead of Mason
    terraform-ls
    tflint
    terraform-docs
    trivy
    checkov
    go
    gopls
    golangci-lint
    delve
    gofumpt
    gotools
    basedpyright
    ruff
    uv
    bash-language-server
    shellcheck
    shfmt
    nixd
    nixfmt
    lua-language-server
    stylua
    tree-sitter
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "naviat";
        email = "haidv.ict@gmail.com";
      };
      github.user = "naviat";
      init.defaultBranch = "main";
    };
  };
  programs.fzf = {
    enable = true; # Ctrl-R history, Ctrl-T files, Alt-C dirs
    defaultCommand = "rg --files";
    defaultOptions = [
      "--height=70%"
      "--preview='bat {}'"
      "--preview-window=right:60%:wrap"
    ];
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;
    history = {
      size = 1000000;
      save = 1000000;
      extended = true;
      ignoreAllDups = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      plugins = [
        "git"
        "aws"
        "kubectl"
        "helm"
        "terraform"
        "gcloud"
        "npm"
        "pip"
        "colored-man-pages"
      ];
      theme = ""; # starship draws the prompt
    };
    initContent = ''
      bindkey '^f' autosuggest-accept

      # work-only aliases and functions, kept out of this public repo
      [ -f "$HOME/.zsh/work.zsh" ] && source "$HOME/.zsh/work.zsh"
    ''
    + builtins.readFile ./zsh/env.zsh
    + builtins.readFile ./zsh/aliases.zsh
    + builtins.readFile ./zsh/functions.zsh;
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      push = "git push";
      pull = "git pull";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
      update = "source ~/.zshrc";
      kctx = "kubectx";
      kns = "kubens";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      kubernetes = {
        disabled = false;
        format = "[$symbol$context( \\($namespace\\))]($style) ";
      };
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };
}

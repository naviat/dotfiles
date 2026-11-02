{ pkgs, user, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = user;
  system.stateVersion = 6;

  # Both accounts, so home-manager knows their home folders
  users.users."harry-nix".home = "/Users/harry-nix";
  users.users.harry.home = "/Users/harry";

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };

  # No global compinit, which removes the y/n prompt for every account
  programs.zsh.enableGlobalCompInit = false;

  # CLI tools for every account (fzf and direnv come from home-manager in common.nix)
  environment.systemPackages = with pkgs; [
    asdf-vm
    pyenv
    kubectl
    kubernetes-helm
    k9s
    awscli2
  ];

  nix-homebrew = {
    enable = true;
    user = user;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "none";   # was "zap", which deleted your old tools
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    taps = [
      "warrensbox/tap"
      "hashicorp/tap"
      "incoai/tap"
      # add other taps only if something below needs them
    ];
    brews = [
      "herdr"
      "hashicorp/tap/terraform"   # nixpkgs lags the latest release
      "warrensbox/tap/tgswitch"
      "incoai/tap/splash"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "iterm2"
      "zed"
    ];
  };
}

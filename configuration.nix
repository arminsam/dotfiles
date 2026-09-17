{ identity, ... }:

let
  localCasks =
    if builtins.pathExists ./local-casks.nix
    then import ./local-casks.nix
    else [];
in

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin"; # use x86_64-darwin for Intel CPU

  system.primaryUser = identity.userName;
  users.users.${identity.userName} = {
    home = "/Users/${identity.userName}";
  };
  system.stateVersion = 6;

  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = false;  # keep the menu bar always visible
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = true;              # tap to click
  };
  nix-homebrew = {
    enable = true;
    user = identity.userName;
    autoMigrate = true;	# Automatically migrates your existing Homebrew installation
  };
  homebrew = {
    enable = true;
    # Keep unlisted casks/formulae installed; only install/upgrade what is listed.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    # Public / everyday casks. Sensitive apps go in local-casks.nix (gitignored).
    casks = [
      "wezterm"
      "sublime-text"
      "jordanbaird-ice"   # menu bar manager (hide/show items)
      "stats"             # system monitor (CPU/memory/network in menu bar)
    ] ++ localCasks;
  };
}

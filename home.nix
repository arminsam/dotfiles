{ config, pkgs, identity, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
in

{
  home.username = identity.userName;
  home.homeDirectory = "/Users/${identity.userName}";
  home.stateVersion = "26.05";
  home.packages = with pkgs; [
    # cli i use constantly
    ripgrep   # fast search
    fd        # fast find
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";

  # macOS Control Center menu-bar items (ByHost / -currentHost prefs).
  # These require a Control Center restart (`killall ControlCenter`) or re-login.
  targets.darwin.currentHostDefaults."com.apple.controlcenter" = {
    Battery = 18;                  # 18 = show battery icon in menu bar, 24 = hide
    BatteryShowPercentage = true;  # show the % text next to the icon
    Bluetooth = 18;                # 18 = show bluetooth icon in menu bar, 24 = hide
  };

  # Menu-bar clock (all-hosts pref). Show the date beside the time.
  # Restart with `killall SystemUIServer` (or re-login) to take effect.
  targets.darwin.defaults."com.apple.menuextra.clock" = {
    ShowDate = 1;         # 0 = when space allows, 1 = always, 2 = never
    ShowDayOfWeek = false;  # keep it minimal: no weekday
    Show24Hour = true;      # 24-hour time
    ShowSeconds = false;    # no seconds
  };

  # Hide the Siri icon from the menu bar.
  targets.darwin.defaults."com.apple.Siri".StatusMenuVisible = false;

  # Ice menu-bar manager basic config (installed as a cask in configuration.nix).
  # Reveal hidden items on hover/click/scroll, and auto re-hide them again.
  # Note: enable "Launch at login" once in Ice's settings (not a defaults key).
  targets.darwin.defaults."com.jordanbaird.Ice" = {
    ShowIceIcon = true;         # show Ice's control (divider) icon in the menu bar
    ShowOnHover = true;         # reveal hidden items when hovering the menu bar
    ShowOnClick = false;        # do NOT reveal on clicking an empty area
    ShowOnScroll = true;        # reveal hidden items by scrolling in the menu bar
    AutoRehide = true;          # automatically re-hide items after showing
    ShowSectionDividers = true; # show the section divider icons
    UseIceBar = true;           # show hidden items in a separate Ice Bar strip
    IceBarLocation = 2;         # Ice Bar position (mirrors the UI selection)
  };

  # Stats system monitor basic config (installed as a cask in configuration.nix).
  # Minimalistic "mini" widgets = an icon + a live value per module.
  # Note: enable "Start at login" once in Stats' settings (not a defaults key).
  targets.darwin.defaults."eu.exelban.Stats" = {
    CPU_state = true;             # enable CPU module
    CPU_widget = "mini";          # compact widget: text label + value
    CPU_mini_label = true;        # show "CPU" text label (Stats can't show a chip icon)
    RAM_state = true;             # enable memory module
    RAM_widget = "mini";          # compact widget: text label + value
    RAM_mini_label = true;        # show "RAM" text label
    Network_state = true;         # enable network module
    Network_widget = "speed";     # upload/download speed readout
    Disk_state = false;           # keep disk module off
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid
    initContent = ''
      bindkey '^f' autosuggest-accept
    '';
    shellAliases = {
      cda = "cd ~/Projects/github";
      ga = "git add .";
      gps = "git push origin";
      gpl = "git pull origin";
      gmg = "git merge";
      gc = "git commit -m";
      gs = "git status";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file.".config/wezterm".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
}

{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
    inputs.mprissence.homeManagerModules.default
  ];

  home.username = "misty";
  home.homeDirectory = "/home/misty";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  gtk.enable = true; # required for home.pointerCursor's gtk integration to actually apply
  # KDE/System Settings keeps (re)writing ~/.gtkrc-2.0, which otherwise makes
  # home-manager activation fail with "would be clobbered" on every rebuild.
  gtk.gtk2.force = true;

  # noctalia only sets dconf color-scheme + writes GTK CSS color overrides; it doesn't
  # flip this flag. Without it, GTK apps and Chromium-based browsers (prefers-color-scheme
  # for web content) default to light even though the rest of the desktop is dark.
  gtk.gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
  gtk.gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;

  home.pointerCursor = {
    enable = true;
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Classic";
    size = 24;
    gtk.enable = true;
    x11.enable = true; # also covers Xwayland
  };

  programs.git = {
    enable = true;
    settings.user = {
      name = "misty";
      email = "matveychan88@gmail.com";
    };
  };

  # niri itself is enabled system-wide (programs.niri.enable in modules/common.nix);
  # this just ships the user config.
  xdg.configFile."niri/config.kdl".source = ./niri/config.kdl;

  programs.noctalia = {
    enable = true;
    systemd.enable = true;
    settings = {
      theme = {
        mode = "dark";
        source = "wallpaper";
        wallpaper_scheme = "m3-content";
        builtin = "Catppuccin"; # fallback if source is switched back to "builtin"
      };
      wallpaper = {
        enabled = true;
        default.path = "/home/misty/Pictures/wallhaven-jeedjw.jpg";
      };
    };
  };

  # Discord rich presence for MPRIS players (~/Documents/mprissence).
  services.mprissence = {
    enable = true;
    settings = {
      client_id = "1558177000827392060";
      ignore = [ "firefox" "chromium" "vivaldi" "telegram-desktop" "Telegram" ];
      show_paused = true;
      small_image = "nixos-logo";
      small_text = "Listening on Nix";
    };
  };

  home.packages =
    let pkgSets = import ../../modules/packages.nix { inherit pkgs; };
    in pkgSets.infosec ++ pkgSets.dev ++ (with pkgs; [
      xwayland-satellite
      alacritty
      fuzzel
      wl-clipboard
      grim
      slurp
      brightnessctl
      vivaldi
      claude-code
      kdePackages.kate
      telegram-desktop
      onlyoffice-desktopeditors
      vscode
      wine
      vesktop
      obsidian
      gns3-gui
      gns3-server
      dynamips
      feishin
      deezer-desktop
      p7zip
    ]);
}

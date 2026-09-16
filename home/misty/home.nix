{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "misty";
  home.homeDirectory = "/home/misty";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  gtk.enable = true; # required for home.pointerCursor's gtk integration to actually apply

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
        source = "builtin";
        builtin = "Catppuccin";
      };
      wallpaper.enabled = false; # TODO: point at a wallpaper once you have one
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
    ]);
}

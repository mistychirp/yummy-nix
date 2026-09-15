{ config, pkgs, inputs, ... }:

{
  imports = [
    inputs.noctalia.homeModules.default
  ];

  home.username = "misty";
  home.homeDirectory = "/home/misty";
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;

  programs.git = {
    enable = true;
    settings.user = {
      name = "misty"; # TODO: set your display name
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
      gns3
    ]);
}

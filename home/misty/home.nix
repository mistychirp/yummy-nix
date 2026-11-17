{ config, pkgs, lib, inputs, osConfig, ... }:

{
  imports = [
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

  # Light or dark is makshell's to say (Settings > Appearance), by GNOME's interface settings in
  # dconf, which outlast the session. A dark flag here would win over it.

  home.pointerCursor = {
    enable = true;
    package = pkgs.apple-cursor;
    name = "macOS";
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
    # Remember the HTTPS token in the Secret Service (KWallet) instead of
    # prompting on every push.
    settings.credential.helper = "${pkgs.gitFull}/bin/git-credential-libsecret";
  };

  # macOS app icons come with makshell, which builds the MacOS-Like themes for the apps there are
  # into ~/.local/share/icons, and picks the light or dark one.

  # Discord rich presence for MPRIS players (~/Documents/mprissence).
  services.mprissence = {
    enable = true;
    settings = {
      client_id = "1558177000827392060";
      ignore = [ "firefox" "chromium" "vivaldi" "telegram-desktop" "Telegram" ];
      show_paused = true;
      small_image = "nixos-logo";
      small_text = "Listening on Nix [{player}]";
      deezer_contributors = true;
      # Feishin's Navidrome covers, via the cover proxy on bun (~/mprissence-covers).
      navidrome = {
        server = "http://mistyworks.servebeer.com:4533";
        cover_url = "https://covers.tail0503bf.ts.net/cover/{id}";
      };
    };
  };

  home.packages =
    let pkgSets = import ../../modules/packages.nix { inherit pkgs; };
    in pkgSets.infosec ++ pkgSets.dev ++ (with pkgs; [
      alacritty
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
      aseprite
      godot
      git-lfs
      # Off until nixpkgs fixes its build: since nixpkgs f9a75f4 (2026-11-05), its node_modules
      # hash doesn't match.
      # anytype
      anytype-cli
      opencode
      jq
      libimobiledevice
      ideviceinstaller
      altserver-linux
    ]);
}

{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.noctalia.nixosModules.default
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    warn-dirty = false;
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nixpkgs.config.allowUnfree = true;

  # TODO: check this matches your actual timezone/locale
  time.timeZone = "Europe/Moscow";
  i18n.defaultLocale = "en_US.UTF-8";

  networking.networkmanager.enable = true;

  users.users.misty = {
    isNormalUser = true;
    description = "misty";
    extraGroups = [ "wheel" "networkmanager" "wireshark" ];
    shell = pkgs.fish;
  };
  programs.fish.enable = true;

  # lets misty run wireshark/dumpcap without sudo
  programs.wireshark.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # --- Wayland session: niri + noctalia shell, with Plasma as a fallback DE ---
  programs.niri.enable = true;

  programs.noctalia.enable = true;
  programs.noctalia.recommendedServices.enable = true;

  # Full KDE Plasma, kept as a working fallback session in case niri/noctalia
  # break or you just want a "normal" DE for a bit.
  services.desktopManager.plasma6.enable = true;

  services.greetd = {
    enable = true;
    # No --cmd: tuigreet lists every session it finds in wayland-sessions/
    # xsessions (niri + plasma here) and lets you pick with the arrow keys;
    # --remember sticks with whatever you picked last time.
    settings.default_session.command =
      "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --remember-session";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gnome ];
  };

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  environment.systemPackages =
    (import ./packages.nix { inherit pkgs; }).base
    ++ [ pkgs.kdePackages.plasma-meta ];

  security.sudo.wheelNeedsPassword = true;

  # TODO: bump only when you know what you're doing, see man configuration.nix
  system.stateVersion = "25.05";
}

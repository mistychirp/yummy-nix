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

  time.timeZone = "Europe/Samara";
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
  # niri and plasma6 both want to set the default greetd session; niri wins.
  services.displayManager.defaultSession = lib.mkForce "niri";

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
      "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
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

  # services.desktopManager.plasma6.enable already pulls in the full Plasma desktop.
  environment.systemPackages = (import ./packages.nix { inherit pkgs; }).base;

  security.sudo.wheelNeedsPassword = true;
  # Lets misty run rebuilds (e.g. from Claude Code, which has no TTY for a
  # sudo password prompt) without a password; everything else on wheel still
  # needs one.
  security.sudo.extraRules = [
    {
      users = [ "misty" ];
      commands = [
        {
          command = "/run/current-system/sw/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Set to the release the system was first installed with; do not bump casually.
  system.stateVersion = "26.05";
}

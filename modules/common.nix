{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    inputs.makshell.nixosModules.default    
  ];

  programs.appimage = { enable = true; binfmt = true; };
  
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

  # Track the newest stable kernel branch on both machines instead of
  # nixpkgs' default `linuxPackages` alias (which lags behind).
  boot.kernelPackages = pkgs.linuxPackages_latest;

  time.timeZone = "Asia/Baku";
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

  # Lets prebuilt generic-linux binaries (e.g. the VS Code Claude Code
  # extension's bundled `claude`) run on NixOS.
  programs.nix-ld.enable = true;

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # --- Wayland session: makshell on KWin, with Plasma as a fallback DE ---
  # The makshell desktop (github:mistychirp/makshell), as its own login session.
  programs.makshell.enable = true;
  # KWallet has no D-Bus activation file for the Secret Service: Plasma starts it itself, and
  # nothing here does, so apps asking for it would otherwise find no one home.
  services.dbus.packages = [
    (pkgs.writeTextDir "share/dbus-1/services/org.freedesktop.secrets.service" ''
      [D-BUS Service]
      Name=org.freedesktop.secrets
      Exec=${pkgs.kdePackages.kwallet}/bin/ksecretd
    '')
  ];
  # Plasma wants to be the default session; makshell is.
  services.displayManager.defaultSession = lib.mkForce "makshell";

  # Fira Sans has no Nerd Font build (Nerd Fonts only patches monospace fonts),
  # so it's the plain package.
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    fira-sans
  ];

  # Full KDE Plasma, kept as a working fallback session in case makshell
  # breaks or you just want a "normal" DE for a bit.
  services.desktopManager.plasma6.enable = true;

  services.greetd = {
    enable = true;
    # No --cmd: tuigreet lists every session it finds in wayland-sessions/
    # xsessions (makshell + plasma here) and lets you pick with the arrow keys;
    # --remember sticks with whatever you picked last time.
    settings.default_session.command =
      "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-session";
  };

  security.polkit.enable = true;

  xdg.portal.enable = true;

  services.flatpak.enable = true;

  # USB multiplexing daemon so libimobiledevice can talk to an iPhone.
  services.usbmuxd.enable = true;
  # apple-mfi-fastcharge grabs the iPhone first and its config switch races
  # usbmuxd (set config fails with -110/-71), leaving the phone unconfigured.
  boot.blacklistedKernelModules = [ "apple-mfi-fastcharge" ];

  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # services.desktopManager.plasma6.enable already pulls in the full Plasma desktop.
  environment.systemPackages = (import ./packages.nix { inherit pkgs; }).base ++ [
    (pkgs.callPackage ../pkgs/artcraft-launcher.nix { src = inputs.craft-launcher; })
    pkgs.mpv
  ];

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

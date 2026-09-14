{ config, pkgs, lib, ... }:

# ThinkPad T460p (i7-6700HQ) specifics: power management, touchpad, backlight.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.tlp.enable = true;
  # tlp and power-profiles-daemon fight over the same knobs, keep only one.
  services.power-profiles-daemon.enable = false;

  services.thermald.enable = true;

  services.libinput.enable = true;

  programs.light.enable = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Intel graphics (HD 530 on the 6700HQ)
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}

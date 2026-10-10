{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # host-specific overrides for the 3600 box go here

  # RGB control (motherboard/fans/RAM). The service also wires up the
  # i2c-dev kernel module + udev rules, so it works without sudo.
  services.hardware.openrgb.enable = true;
  environment.systemPackages = [ pkgs.openrgb pkgs.modrinth-app pkgs.ddcutil ];
}

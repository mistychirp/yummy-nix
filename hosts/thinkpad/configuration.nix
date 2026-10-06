{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./happ-nixos/happ-module.nix
  ];

  networking.hostName = "thinkpad";
  services.happ.enable = true;

  # host-specific overrides for the T460p go here
}

{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad";

  # host-specific overrides for the T460p go here
}

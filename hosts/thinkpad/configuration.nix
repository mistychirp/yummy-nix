{ config, pkgs, inputs, options, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "thinkpad";

  # host-specific overrides for the T460p go here
  services.v2raya = {
    enable = true;
    cliPackage = pkgs.xray;
  };

  programs.amnezia-vpn.enable = true;
}

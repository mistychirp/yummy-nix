{ config, pkgs, lib, ... }:

# Desktop (Ryzen 5 3600): RX 5700 XT discrete GPU, amdgpu driver.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}

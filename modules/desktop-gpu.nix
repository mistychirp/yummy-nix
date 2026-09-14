{ config, pkgs, lib, ... }:

# Desktop (Ryzen 5 3200G): Vega 8 integrated graphics, amdgpu driver.
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };
}

{ config, lib, pkgs, modulesPath, ... }:

# PLACEHOLDER. After installing NixOS on this machine, replace this whole
# file with the output of:
#   nixos-generate-config --root /mnt --show-hardware-config > hosts/thinkpad/hardware-configuration.nix
# Do not hand-edit filesystems/UUIDs/kernel modules — they're hardware-detected.
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.availableKernelModules = [ ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  swapDevices = [ ];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}

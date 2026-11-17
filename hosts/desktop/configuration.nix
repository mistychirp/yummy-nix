{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # host-specific overrides for the 3600 box go here

  # macOS (Hackintosh) via OpenCore, chainloaded from systemd-boot. OpenCore itself
  # is copied to /boot/EFI/OC by ~/Projects/hackintosh/install_opencore.sh.
  boot.loader.systemd-boot.extraEntries."macos.conf" = ''
    title macOS Tahoe
    efi /EFI/OC/OpenCore.efi
    sort-key z_macos
  '';

  # RGB control (motherboard/fans/RAM). The service also wires up the
  # i2c-dev kernel module + udev rules, so it works without sudo.
  services.hardware.openrgb.enable = true;
  environment.systemPackages = [ pkgs.openrgb pkgs.modrinth-app pkgs.ddcutil pkgs.limo ];

  # Steam (also pulls in Proton support and 32-bit graphics libraries).
  programs.steam.enable = true;
  # GE-Proton, managed by Nix (shows up in Steam's compatibility tool list).
  programs.steam.extraCompatPackages = [ pkgs.proton-ge-bin ];

  # Extra data drives, mounted at boot at the same paths Dolphin/udisks used,
  # so existing paths (Steam library, Limo/Vortex mod folders) keep working.
  # "nofail" = boot continues normally if a drive is missing or broken.
  fileSystems."/run/media/misty/MemoryBox" = {
    device = "/dev/disk/by-uuid/4be7136a-f1bf-445e-b580-5c0fa7a645f7";
    fsType = "ext4";
    options = [ "nofail" "x-systemd.device-timeout=10s" ];
  };

  fileSystems."/run/media/misty/Junkyard" = {
    device = "/dev/disk/by-uuid/E66C18B46C18820B";
    fsType = "ntfs3";
    options = [ "uid=1000" "gid=100" "iocharset=utf8" "prealloc" "nofail" "x-systemd.device-timeout=10s" ];
  };
}

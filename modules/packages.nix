{ pkgs }:

# Shared package lists, pulled into both NixOS (environment.systemPackages)
# and home-manager (home.packages). Split by category so you can grow each
# independently; `base` goes system-wide, `infosec`/`dev` are user-level.
#
# NOTE: this repo was scaffolded before either machine had Nix installed, so
# these names haven't been checked against `nix search nixpkgs <name>` yet —
# do that before your first `nixos-rebuild switch` / `home-manager switch`
# and drop anything that moved or got renamed.
{
  base = with pkgs; [
    git
    neovim
    wget
    curl
    htop
    tmux
    ripgrep
    fd
    unzip
  ];

  # Starter infosec toolkit — trim/extend as your actual workflow settles.
  infosec = with pkgs; [
    nmap
    tcpdump
    wireshark
    netcat-gnu
    socat
    nikto
    sqlmap
    gobuster
    ffuf
    masscan
    binwalk
    radare2
    john
    hashcat
    aircrack-ng
    thc-hydra
    burpsuite # unfree, needs nixpkgs.config.allowUnfree (already on in common.nix)
  ];

  dev = with pkgs; [
    # TODO: languages/editors/toolchains you actually use
  ];
}

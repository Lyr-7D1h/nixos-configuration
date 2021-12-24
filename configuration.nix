# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [
      # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/home-manager.nix
      ./modules/gnome.nix
      ./pkgs/macchanger.nix
    ];

  # Enable FN Keys for keychron: https://mikeshade.com/posts/keychron-linux-function-keys/
  boot.kernelParams = [ "hid_apple.fnmode=0" ];
  boot.loader.efi.canTouchEfiVariables = true;
  # Increase map count, needed for Star Citizen: https://robertsspaceindustries.com/spectrum/community/SC/forum/51473/thread/linux-install-starcitizen-to-linux-howto
  boot.kernel.sysctl = {"vm.max_map_count" = 16777216; };
  boot.loader.grub = {
    enable = true;
    default = "saved";
    version = 2;
    device = "nodev";
    efiSupport = true;
    useOSProber = true;
  };
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.initrd.luks = {
    reusePassphrases = true;
    devices = {
      cryptroot = {
        device = "/dev/disk/by-uuid/7f775eb3-bf22-401c-87af-04e10287087b";
        preLVM = true;
        allowDiscards = true;
      };
      cryptback1 = {
        device = "/dev/disk/by-uuid/5c150675-091f-4d15-899d-a97845bc550b";
        preLVM = true;
      };
      cryptback2 = {
        device = "/dev/disk/by-uuid/308562ac-35ff-4c67-ab59-47923f68c014";
        preLVM = true;
        allowDiscards = true;
      };
    };
  };
  # Needed for probing windows os
  boot.supportedFilesystems = [ "ntfs" ];

  

  virtualisation.libvirtd.enable = true;
  virtualisation.docker.enable = true;
  programs.dconf.enable = true;

  programs.zsh.enable = true;
  programs.steam.enable = true;

  environment.variables.EDITOR = "nvim";

  users.users = {
    lyr = {
      description = "Lyr 7D1h";
      extraGroups = [ "wheel" "audio" "libvirtd" "docker" ];
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };

  programs.gnupg.agent.enable = true;


  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  networking = {
    hostName = "home"; 
    # Define your hostname.
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
    interfaces.enp39s0.useDHCP = true;
    firewall = {
      enable = true;
    };
    nameservers = [ "1.1.1.1" "1.0.0.1" ];
  };

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.layout = "us";

  sound.enable = true;
  services.ofono.enable = true;
  hardware = {
    # https://nixos.wiki/wiki/AMD_GPU
    opengl = {
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        rocm-opencl-icd
        rocm-opencl-runtime
        amdvlk
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
    enableAllFirmware = true;
    pulseaudio = {
      enable = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      package = pkgs.pulseaudioFull;
      extraConfig = "
      load-module module-switch-on-connect
      ";

    };
    bluetooth = {
      enable = true;
      package = pkgs.bluez5;
      disabledPlugins = [ "sap" ];
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    virt-manager
    nixpkgs-fmt
    wget
    pavucontrol
    lsof # List open files
    file
    htop
    tmux
    vim
    nfs-utils
    git-remote-gcrypt # Encrypt git repos
  ];


  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = https://nixos.org/channels/nixos-21.11;

  system.stateVersion = "21.05";
}


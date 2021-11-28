# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./modules/home-manager.nix
    ];

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub = {
	enable = true;
	version = 2;
	device = "nodev";
	efiSupport = true;
	useOSProber = true;
  };
  boot.initrd.luks = {
	reusePassphrases = true;
	devices = {
		cryptroot = {
			device = "/dev/disk/by-uuid/7f775eb3-bf22-401c-87af-04e10287087b";
			preLVM = true;
			allowDiscards = true;
		};
		cryptback1= {
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
  boot.supportedFilesystems = [ "ntfs" ];

  services.xserver.enable = true;
  services.xserver.desktopManager.gnome = {
  	enable = true;
	extraGSettingsOverridePackages = with pkgs; [ gnome3.gnome-settings-daemon ];
	extraGSettingsOverrides = ''
		[org/gnome/settings-daemon/plugins/media-keys]
		custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']
		screensaver=['<Shift><Super>underscore']
		www=@as []

		[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
		binding='<Super>Return'
		command='gnome-terminal'
		name='Gnome Terminal'
	'';
  };
  services.xserver.displayManager.gdm.enable = true;

  programs.zsh.enable = true;
  programs.steam.enable = true;

  environment.variables.EDITOR = "nvim";

  users.users = {
	lyr = {
		description = "Lyr 7D1h";
		extraGroups = [ "wheel" "audio" ];
		isNormalUser = true;
		shell = pkgs.zsh;
	};
  };

  programs.gnupg.agent.enable = true;

  networking.hostName = "home"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp39s0.useDHCP = true;
  networking.interfaces.wlo1.useDHCP = true;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  # };


  
  # Configure keymap in X11
  # services.xserver.layout = "us";
  # services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  security = {
  	rtkit.enable = true;
  };
  services.pipewire = {
	  enable = true;
	  alsa.enable = true;
	  alsa.support32Bit = true;
	  pulse.enable = true;
	  # If you want to use JACK applications, uncomment this
	  #jack.enable = true;

	  # use the example session manager (no others are packaged yet so this is enabled by default,
	  # no need to redefine it in your config for now)
	  #media-session.enable = true;
	  media-session.config.bluez-monitor.rules = [
	     {
	      # Matches all cards
	      matches = [ { "device.name" = "~bluez_card.*"; } ];
	      actions = {
		"update-props" = {
		  "bluez5.reconnect-profiles" = [ "hfp_hf" "hsp_hs" "a2dp_sink" ];
		  # mSBC is not expected to work on all headset + adapter combinations.
		  "bluez5.msbc-support" = true;
		  # SBC-XQ is not expected to work on all headset + adapter combinations.
		  "bluez5.sbc-xq-support" = true;
		};
	      };
	    }
	    {
	      matches = [
		# Matches all sources
		{ "node.name" = "~bluez_input.*"; }
		# Matches all outputs
		{ "node.name" = "~bluez_output.*"; }
	      ];
	      actions = {
		"node.pause-on-idle" = false;
	      };
	    }
	  ];
  };
  sound.enable = false;
  hardware = {
	enableAllFirmware = true;
  	pulseaudio = {
		  enable = false;
#		  extraModules = [ pkgs.pulseaudio-modules-bt ];
#		  package = pkgs.pulseaudioFull;
#		  extraConfig = "
#				load-module module-switch-on-connect
#		  ";
  		
	  };
	  bluetooth = {
	  	enable = true;
		package = pkgs.bluezFull;
		disabledPlugins = [ "sap" ];
	  };
  };


  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    	wget
	lsof # List open files
	file
	htop
	tmux
	vim
	terraform
	gnome.dconf-editor
	git-remote-gcrypt # Encrypt git repos
	(let 
	  my-python-packages = python-packages: with python-packages; [ 
	    pandas
	    requests
	    autopep8
	  ];
	  python-with-my-packages = python3.withPackages my-python-packages;
	in
	python-with-my-packages)

  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:
  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.05"; # Did you read the comment?

}


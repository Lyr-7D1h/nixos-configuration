{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  home-manager.users.lyr = {
	nixpkgs.config.allowUnfree = true;
	home.packages = [ 
		pkgs.spotify 
		pkgs.neovim 
		pkgs.firefox
		pkgs.alacritty
	];
	# Bluetooth headset media control
	services.mpris-proxy.enable = true;

	services.gpg-agent.enable = true;
	programs.git = {
	    enable = true;
	    userName  = "lyr";
	    userEmail = "lyr-7d1h@pm.me";
	};
	programs.vscode = {
		enable = true;
	};
	programs.zsh = {
	  enable = true;
	  shellAliases = {
	    update = "sudo nixos-rebuild switch";
	  };
	  oh-my-zsh = {
	  	enable = true;
		plugins = [ "git" ];
	  };
	};
  };
}

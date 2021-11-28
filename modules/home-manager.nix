{ config, pkgs, ... }:
let
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.05.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

 nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];
  home-manager.users.lyr = {
	nixpkgs.config.allowUnfree = true;

	home.packages = [ 
		pkgs.spotify 
		pkgs.firefox
		pkgs.alacritty
		pkgs.chromium
		pkgs.qbittorrent
        pkgs.kubectl
	];
	# Bluetooth headset media control
	services.mpris-proxy.enable = true;

	services.gpg-agent.enable = true;

	programs.git = {
	    enable = true;
	    userName  = "lyr";
	    userEmail = "lyr-7d1h@pm.me";
	};

	programs.neovim = {
		enable = true;
		package = pkgs.neovim-nightly;
		vimAlias = true;
		viAlias = true;
		plugins = with pkgs.vimPlugins; [
			vim-nix
			vim-commentary
			vim-toml
			auto-pairs
		];
		extraConfig = ''
			set number
			set tabstop=4
			set shiftwidth=4
			set clipboard=unnamedplus

			let mapleader=";"

			" Always use original yank when pasting
			noremap <Leader>p "0p
			noremap <Leader>P "0P
			vnoremap <Leader>p "0p

			" Easier Split Navigation
			nnoremap <C-j> <C-W><C-J>
			nnoremap <C-k> <C-W><C-K>
			nnoremap <C-l> <C-W><C-L>
			nnoremap <C-h> <C-W><C-H>
		'';
	};

	programs.vscode = {
		enable = true;
	};

	programs.zsh = {
	  enable = true;
	  shellAliases = {
	    update = "sudo nixos-rebuild switch";
	    ssh = "TERM=xterm ssh";
	    tf = "terraform";
	    configure = "vim /etc/nixos/configuration.nix";
	    configure-home = "vim /etc/nixos/modules/home-manager.nix";
	  };
	  initExtra = ''
		source ~/.p10k.zsh
		if [[ -n $SSH_CONNECTION ]]; then
		  export EDITOR='vim'
		else
		  export EDITOR='nvim'
		fi
		
		bindkey '^ ' autosuggest-accept
		
		# Fix screen coloring since most remote clients don't support alacritty
		alias ssh="TERM=xterm ssh"
	  '';
	  zplug = {
	    enable = true;
	    plugins = [
	      { name = "zsh-users/zsh-autosuggestions"; }
	      { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
	    ];
	  };
	};
  };
}

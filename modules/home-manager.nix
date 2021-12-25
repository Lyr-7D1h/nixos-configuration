{ config, pkgs, ... }:
let
   unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/release-21.11)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
  # unstableTarball =
    # fetchTarball
    #   https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  # nixpkgs.config = {
  #   packageOverrides = pkgs: {
  #     unstable = import unstableTarball {
  #       config = config.nixpkgs.config;
  #     };
  #   };
  # };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    # (import ../overlays/terraformLatest.nix)
    # (import ../overlays/torbrowser.nix)
  ];


  home-manager.users.lyr = {
	nixpkgs.config.allowUnfree = true;

	home.packages = with pkgs; [ 
        # torbrowserLatest
        omnisharp-roslyn # c# support
        dotnet-sdk # c support
        wl-clipboard
        ripgrep
        gimp
        yarn
        rustup
        unstable.tor-browser-bundle-bin
        minikube
        winePackages.full
        winetricks
        lutris
        minecraft
        vlc
        nodejs-14_x
        gnumake
        jq
        awscli2
        neofetch
        postman
        sshpass # connect using ssh with password arg
        ansible
		spotify 
		firefox
		alacritty
		chromium
		qbittorrent
        kubectl
        nmap
        terraform
        discord
        element-desktop
        bitwarden
        bitwarden-cli
        slack
        (
          let
            my-python-packages = python-packages: with python-packages; [
              pandas
              requests
              autopep8
            ];
            python-with-my-packages = python3.withPackages my-python-packages;
          in
          python-with-my-packages
        )
	];
	# Bluetooth headset media control
	# services.mpris-proxy.enable = true;

	services.gpg-agent.enable = true;

    programs.go.enable = true;
	programs.git = {
	    enable = true;
	    userName  = "lyr";
	    userEmail = "lyr-7d1h@pm.me";
        extraConfig = {
          pull = { rebase = false; };
          init = { defaultBranch = "master"; };
        };
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
            nvim-cm-racer
		];
		extraConfig = ''
set number
set tabstop=4
set shiftwidth=4
set clipboard+=unnamedplus

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
        extensions = with pkgs.vscode-extensions; [
           asvetliakov.vscode-neovim 
        ];
	};
    systemd.user.services = {
      daily-paper = {
        Unit = {
          Description = "Set your daily wallpaper";
        };

        Service = {
          ExecStart = "/home/lyr/bin/daily_paper";
          Type = "oneshot";
        };

        Install = {
          WantedBy= [ "default.target" ];
        };
      };
    };
    # Automatically start services
    systemd.user.startServices = "sd-switch";

    programs.tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      extraConfig = ''
set -s copy-command 'wl-copy'

# Allow scrolling with mouse
set -g mouse on
# Vim keybindings in copy-mode
set-window-option -g mode-keys vi

# Vi bindings for moving between planes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R
'';
    };

	programs.zsh = {
	  enable = true;
	  shellAliases = {
	    update = "sudo nixos-rebuild switch";
	    ssh = "TERM=xterm ssh";
	    tf = "terraform";
	    configure = "vim /etc/nixos/configuration.nix";
	    configure-home = "vim /etc/nixos/modules/home-manager.nix";
        configure-gnome = "vim /etc/nixos/modules/gnome.nix";
	  };
	  initExtra = ''
source ~/.p10k.zsh

if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

# set emacs keybinds (ctrl+a, ctrl+e)
bindkey -e

# ctrl + space to accept suggestions
bindkey '^ ' autosuggest-accept

autoload -U select-word-style
select-word-style bash

# normal alt backspace for removing words
bindkey '^[^?' backward-kill-word

# Enable reverse search
bindkey '^R' history-incremental-search-backward

# alt + <- and alt + -> move a word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey  "^[[H"   beginning-of-line
bindkey  "^[[F"   end-of-line
bindkey  "^[[3~"  delete-char

# alt + delete remove word
bindkey '^[[3;5~' kill-word

# Adding custom executables
export PATH="$PATH:$HOME/bin"
export PATH="$PATH:$HOME/.npm/bin"
	  '';
	  zplug = {
	    enable = true;
	    plugins = [
          { name = "hanjunlee/terragrunt-oh-my-zsh-plugin"; }
	      { name = "zsh-users/zsh-autosuggestions"; }
	      { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
	    ];
	  };
	};
  };
}

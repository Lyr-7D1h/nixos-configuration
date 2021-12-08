{ config, pkgs, ... }:
let
  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    # (import ../overlays/terraformLatest.nix)
  ];


  home-manager.users.lyr = {
	nixpkgs.config.allowUnfree = true;

	home.packages = with pkgs; [ 
        xclip # needed for nvim system clipboard
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
        nodejs-14_x
	];
	# Bluetooth headset media control
	# services.mpris-proxy.enable = true;

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
	};

    programs.tmux = {
      enable = true;
      clock24 = true;
      extraConfig = ''
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
# set -g @plugin "arcticicestudio/nord-tmux"

# Allow scrolling with mouse
set -g mouse on
# Vim keybindings in copy-mode
set-window-option -g mode-keys vi

# set -g status-bg "#23272a"
# set -g status-fg "#eeeeee"

# Vi bindings for moving between planes
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

run '~/.tmux/plugins/tpm/tpm'
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

# Adding custom executables
export PATH="$PATH:$HOME/bin"
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

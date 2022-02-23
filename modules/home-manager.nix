{ config, pkgs, ... }:
let
   unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/release-21.11)
    # reuse the current configuration
    { config = config.nixpkgs.config; };
  home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-21.11.tar.gz";
in
{
  imports = [
    (import "${home-manager}/nixos")
  ];


  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
    # (import ../overlays/firefox-dev.nix)
    # (import ../overlays/torbrowser.nix)
  ];


  home-manager.users.lyr = {
	nixpkgs.config.allowUnfree = true;

	home.packages = with pkgs; [ 
      cloudflared
      fzf
      libssh # needed for clusterit
      openssl # fixes python libcrypto not found
      binutils # fixes python libcrypto not found
      easyeffects
      wireshark
      gcc
      minikube
      k9s
      poetry
      jetbrains.pycharm-professional
      audacity
      obs-studio
      openconnect
      mono
      libreoffice
      bind # dig and nslookup
      act # Run Github Action locally
      kubernetes-helm
      omnisharp-roslyn # c# support
      dotnet-sdk # c support
      github-cli # used in release script
      wl-clipboard
      ripgrep
      gimp
      yarn
      rustup
      unstable.tor-browser-bundle-bin
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
              oscrypto
              requests
              autopep8
              black
              pipx
              mypy
            ];
            python-with-my-packages = python39.withPackages my-python-packages;
          in
          python-with-my-packages
        )
	];

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
        package = pkgs.vscode-fhsWithPackages (ps: with ps; [ rustup zlib ]);
        # extensions = with pkgs.vscode-extensions; [
        #    asvetliakov.vscode-neovim 
        #    ms-dotnettools.csharp
        # ];
	};
    systemd.user.timers = {
      daily-paper = {
        Unit = {
          Description = "Set your daily wallpaper";
        };
        Timer = {
          Unit = "daily-paper";
          OnUnitActiveSec = "1d";
          Persistent = true; # Start immediately if missed
        };
        Install = {
          WantedBy= [ "timers.target" ];
        };
      };
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
      enableAutosuggestions = true;
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      autocd = true;
      defaultKeymap = "emacs";
	  shellAliases = {
	    update = "sudo nixos-rebuild switch";
	    upgrade = "sudo nixos-rebuild switch --upgrade";
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

# Needed for obs on wayland
export QT_QPA_PLATFORM=wayland

# AWS stuff
export AWS_PROFILE=De-Persgroep---News-Personalisation-squad.dpg-administrator-cf
export AWS_DEFAULT_REGION=eu-west-1
export AWS_DEFAULT_SSO_START_URL=https://d-93677093a7.awsapps.com/start
export AWS_DEFAULT_SSO_REGION=eu-west-1

kaws() {
  selected=$(aws configure list-profiles | fzf)
  export AWS_PROFILE=$selected
}

# Adding custom executables
export PATH="$PATH:$HOME/.npm/bin"
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
	  '';
	  zplug = {
	    enable = true;
	    plugins = [
          { name = "plugins/git"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/aws"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/terraform"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/npm"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/poetry"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/docker"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/docker-compose"; tags = [ from:oh-my-zsh ]; }
          { name = "plugins/tmux"; tags = [ from:oh-my-zsh ]; }
	      { name = "zsh-users/zsh-autosuggestions"; }
	      { name = "romkatv/powerlevel10k"; tags = [ as:theme depth:1 ]; } # Installations with additional options. For the list of options, please refer to Zplug README.
	    ];
	  };
	};
  };
}

{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "rui";
  home.homeDirectory = "/home/rui";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11"; # Please read the comment before changing.
  
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  #nixpkgs.overlays = [
  #  (import (builtins.fetchTarball {
  #    url = "https://github.com/nix-community/emacs-overlay/archive/master.tar.gz";
  #    sha256 = "14vpc0n1w44wr4lqwx0q6ipbc9n3d1cnm6whf0pcnyh5cg10h0z2";
  #  }))
  #];

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    gcc
    cmake
    gnumake
    clang-tools
    brave
    dmenu
    st
    dwm
    dwmblocks
    file
    fira-code
    curl
    wget
    iosevka
    iosevka-bin
    iosevka-comfy.comfy
    ispell
    libnotify
    libvterm
    libtool
    pulsemixer
    texliveFull
    xwallpaper
    xdotool
    xorg.xmodmap
    zotero
    #(emacsWithPackagesFromUsePackage {
    #  config = dotfiles/.config/emacs/init.el;
    #  defaultInitFile = true;
    #  alwaysEnsure = true;
    #})
  ];
  
  fonts.fontconfig.enable = true;

  home.sessionPath = [
    "$HOME/.local/bin"
    "$HOME/.local/bin/statusbar"
    "$HOME/.local/bin/cron"
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    ".local/bin" = {
      source = ../../scripts;
      recursive = true;
    };
    ".config/emacs/init.el".source = ../../dotfiles/emacs/init.el;
    ".local/share/bg".source = ../../backgrounds/thiemeyer_road_to_samarkand.jpg;
  };

  home.sessionVariables = {
    TERMINAL = "st";
    BROWSER = "brave";
    FLAKE = "/home/rui/nixicle/";
    CC = "gcc";
  };

  nixicle = {
    desktop.dwm.enable = true;
    programs = {
      lf.enable = true;
      zathura.enable = true;
      zsh.enable = true;
    };
    services.dunst.enable = true;
  };

  programs = {
    neovim = {
      enable = true;
      defaultEditor = true;
      # extraConfig = lib.fileContents dotfiles/.config/nvim/init.vim;
      viAlias = true;
      vimAlias = true;
    };

    emacs = {
      enable = true;
    };

    git = {
      enable = true;
      userName = "RuiPMaia";
      userEmail = "ruipmaia29@gmail.com";
    };

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    nh.enable = true;
  };
  
  services = {
    emacs.enable = true;
    unclutter.enable = true;
    blueman-applet.enable = true;
  };

  #wayland.windowManager.sway = {
  #  enable = true;
  #  config = rec {
  #    modifier = "Mod1";
  #    terminal = "kitty";
  #    input = {
  #      "*" = {
  #        xkb_layout = "pt";
  #        repeat_delay = "300";
  #        repeat_rate = "50";
  #      };
  #    };
  #  };
  #};
}

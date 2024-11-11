{
  config,
  lib,
  namespace,
  ...
}:
with lib; let
  cfg = config.${namespace}.programs.zsh;
in {
  options.${namespace}.programs.zsh = {
    enable = mkEnableOption "zsh config";
  };

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      dotDir = ".config/zsh";
      enableCompletion = true;
      history = {
        save = 10000000;
        size = 10000000;
        path = "${config.xdg.cacheHome}/zsh/history";
      };
      syntaxHighlighting = {
        enable = true;
        # package = pkgs.zsh-syntax-highlighting;
      };
      autocd = true;
      initExtraBeforeCompInit = ''
      autoload -U colors && colors
      PS1="%B%{$fg[red]%}[%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%M %{$fg[magenta]%}%~%{$fg[red]%}]%{$reset_color%}$%b "'';
      completionInit = ''
      autoload -U compinit
      zstyle ':completion:*' menu select
      zmodload zsh/complist
      compinit
      _comp_options+=(globdots)'';
      profileExtra = ''
      [ "$(tty)" = "/dev/tty1" ] && ! pidof -s Xorg >/dev/null 2>&1 && exec startx $HOME/.config/x11/xsession >/dev/null 2>&1'';
    };
  };
}

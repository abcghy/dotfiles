{ lib, pkgs, ... }:
let
  username = "sakura";
in 
{
  fonts = {
    fontconfig.enable = true;
  };

  home = {
    packages = with pkgs; [
      cmatrix
      lnav

      sttr

      fastfetch btop
      yazi lazygit
      jq
      dysk

      # Terminal beautify
      zsh
      oh-my-posh
      tmux tmuxp

      # Network Related
      # wireshark
      httpie

      # fonts
      maple-mono.NF-CN
    ];

    inherit username;
    homeDirectory = "/home/${username}";

    file = {
      "hello.txt" = {
        text = "echo 'Hello, World!'";
        executable = true;
      };
    };

    stateVersion = "24.11";
  };

  programs.home-manager.enable = true;
}

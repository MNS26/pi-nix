{pkgs, lib, ... }:
{
  home = {
    username = "edgetx";
    homeDirectory = "/home/edgetx";
    stateVersion = "25.11";
  };
  programs.home-manager.enable = true;
}
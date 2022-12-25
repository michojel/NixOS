{ config, lib, pkgs, ... }:
let
in
{

  networking = {
    networkmanager = {
      enable = true;
      enableStrongSwan = true;
      dns = "systemd-resolved";
    };
  };

  systemd.services = {
    # only for laptops
    NetworkManager-wait-online.enable = false;
  };

  services.resolved = {
    enable = true;
    dnssec = "false";
    extraConfig = ''
      MulticastDNS=true
    '';
  };
}

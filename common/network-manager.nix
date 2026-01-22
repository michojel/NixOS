{ config, lib, pkgs, ... }:
let
in
{

  networking = {
    networkmanager = {
      enable = true;
      # enableStrongSwan = true;
      dns = "systemd-resolved";
      plugins = [
        pkgs.networkmanager-openconnect
        pkgs.networkmanager-strongswan
        pkgs.networkmanager-l2tp
        pkgs.networkmanager-vpnc
      ];
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

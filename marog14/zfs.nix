{ config, lib, pkgs, ... }:

{
  boot = {
    zfs = {
      requestEncryptionCredentials = true;
      devNodes = "/dev/";
    };
    supportedFilesystems = [ "zfs" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoScrub.pools = [ "rpool" ];
      autoSnapshot.enable = true;
    };
  };
}

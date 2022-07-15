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
    kernelParams = [ "nohibernate" ];
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoScrub.pools = [ "rpool" "datapool" ];
      autoSnapshot.enable = true;
    };
  };
}

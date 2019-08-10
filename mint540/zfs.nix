{ config, lib, pkgs, ... }:

let
  encryptedPoolName = "enctank";

in {
  boot = {
    zfs = {
      enableUnstable               = true;
      requestEncryptionCredentials = true;
    };
    supportedFilesystems = ["zfs"];
    loader = {
      systemd-boot.enable      = true;
      efi.canTouchEfiVariables = true;
      efi.efiSysMountPoint     = "/boot/EFI";
    };
  };

  services = {
    zfs = {
      autoScrub.enable = true;
      autoSnapshot.enable = true;
    };
  };
}

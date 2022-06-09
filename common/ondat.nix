{ config, pkgs, nodejs, ... }:

# kudos to Richard Kovacs (mhmxs on github.com) for figuring out everything
# Inspired by https://github.com/mhmxs/nixos/blob/main/dev/etc/nixos/configuration.nix

rec {
  boot.kernelModules = pkgs.lib.mkAfter [ "kvm-intel" "uio" "tcm_loop" "target_core_mod" "target_core_user" ];
  boot.extraModprobeConfig = ''
    options kvm_intel nested=1
  '';
  virtualisation.libvirtd.enable = true;
  users.extraUsers.miminar = {
    extraGroups = pkgs.lib.mkAfter [
      "docker"
      "libvirtd"
    ];
  };

  system.activationScripts.nonposix.text = ''
    ln -sf /run/current-system/sw/bin/bash /bin/bash
    rm -rf /lib64 ; ln -sf /run/current-system/sw/lib /lib64
    rm -rf /lib ; ln -sf /run/current-system/kernel-modules/lib /lib
  '';

  networking.extraHosts = ''
    127.0.0.1 storageos.storageos.svc
  '';
}

{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.ondat.kubecover;
in
{
  options.ondat.kubecover = {
    enable = mkEnableOption ''
      Enable the system for ondat/kubecover hacking.
      Please also make sure to add your user to "docker" and "libvirtd" groups like this:

        config.users.extraUsers.YOUR_USER_NAME = {
          ...
          extraGroups = [
            ...
            docker
            libvirtd
          ];
        };
    '';

    systemWideNixFlakes = mkOption {
      type = types.bool;
      description = ''
        Enable system-wide installation of Nix Flakes. If you have your own way
        of Flakes enablement, set this to false.
      '';
      default = true;
    };
  };

  # kudos to Richard Kovacs (mhmxs on github.com) for figuring out everything
  # Inspired by https://github.com/mhmxs/nixos/blob/main/dev/etc/nixos/configuration.nix

  config = mkIf cfg.enable {
    boot.kernelModules = pkgs.lib.mkAfter [ "kvm-intel" "uio" "tcm_loop" "target_core_mod" "target_core_user" ];
    boot.extraModprobeConfig = ''
      options kvm_intel nested=1
    '';
    virtualisation.libvirtd.enable = true;

    system.activationScripts.nonposix.text = ''
      ln -sf /run/current-system/sw/bin/bash /bin/bash
      rm -rf /lib64 ; ln -sf /run/current-system/sw/lib /lib64
      rm -rf /lib ; ln -sf /run/current-system/kernel-modules/lib /lib
    '';

    networking.extraHosts = ''
      127.0.0.1 storageos.storageos.svc
    '';

    environment.systemPackages = mkIf cfg.systemWideNixFlakes [
      (pkgs.writeShellScriptBin "nixFlakes" ''
        exec ${pkgs.nixFlakes}/bin/nix --experimental-features "nix-command flakes" "$@"
      '')
    ];
  };
}

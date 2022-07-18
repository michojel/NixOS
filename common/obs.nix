{ config, lib, pkgs, modulesPath, ... }:

{
  boot = {
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=9 card_label="OBSVirtualCam" exclusive_caps=1
    '';
    kernelModules = [ "v4l2loopback" ];
  };

  environment.systemPackages = with pkgs; [
    obs-studio
  ];
}

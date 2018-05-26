{ config, ... }:

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    storageDriver = "overlay2";
  };
}

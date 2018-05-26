{ config, ... }:

{
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    enableOnBoot = true;
    #extraOptions = "--ipv6";
    storageDriver = "overlay2";
  };
}

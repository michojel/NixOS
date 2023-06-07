{ config, lib, pkgs, ... }:

{
  services.squid = {
    enable = true;
    proxyAddress = "0.0.0.0";
    extraConfig = ''
      #         storage_type  dir              Max-MB  L1 L2
      cache_dir ufs           /var/cache/squid 16384   16 256

      maximum_object_size           512 Mb
      maximum_object_size_in_memory 512 Kb
    '';
  };

  networking.firewall.interfaces.docker0.allowedTCPPorts = [
    3128 # squid proxy
  ];
  networking.firewall.interfaces.vboxnet0.allowedTCPPorts = [
    3128 # squid proxy
  ];
}

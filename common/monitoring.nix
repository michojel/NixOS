{ config, lib, pkgs, ... }:

{
  services = {
    prometheus = {
      enable = true;
      exporters = {
        node = {
          enabledCollectors = [
            "conntrack"
            "diskstats"
            "edac"
            "entropy"
            "filefd"
            "filesystem"
            "hwmon"
            "interrupts"
            "ksmd"
            "loadavg"
            "logind"
            "mdadm"
            "meminfo"
            "netdev"
            "netstat"
            "processes"
            "stat"
            "systemd"
            "tcpstat"
            "time"
            "vmstat"
            "uname"
            "zfs"
          ];
          enable = true;
        };
        dnsmasq.enable = true;
      };
      scrapeConfigs = [
        {
          job_name = "node-exporter";
          scrape_interval = "10s";
          static_configs = [{
            targets = [ "localhost:9100" ];
          }];
        }
      ];
    };
    grafana.enable = true;

    thanos = {
      #sidecar.enable = true;
      #store.enable = true;
      #query.enable = true;
      #rule.enable = true;
      #compact.enable = true;
    };

  };
}

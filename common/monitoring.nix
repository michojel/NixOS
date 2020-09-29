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
            "entropy"
            "filefd"
            "filesystem"
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
            "time"
            "vmstat"
          ];
          enable = true;
        };
        dnsmasq.enable = true;
      };
      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          scrape_interval = "10s";
          static_configs = [
            {
              targets = [
                "localhost:9100"
              ];
              labels = {
                alias = config.networking.hostName;
              };
            }
            #            {
            #              targets = [
            #                "reverse-proxy.example.com:9113"
            #                "reverse-proxy.example.com:9100"
            #              ];
            #              labels = {
            #                alias = "reverse-proxy.example.com";
            #              };
            #            }
            #            {
            #              targets = [
            #                "other-node.example.com:9100"
            #              ];
            #              labels = {
            #                alias = "other-node.example.com";
            #              };
            #            }
          ];
        }
      ];
    };
    grafana.enable = true;

    thanos = {
      #sidecar.enable = true;
      store.enable = true;
      query.enable = true;
      rule.enable = true;
      compact.enable = true;
    };

  };
}

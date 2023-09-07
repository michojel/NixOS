{ config, pkgs, lib, ... }:

{
  virtualisation = {
    virtualbox.host = {
      enable = true;
      enableExtensionPack = true;
    };
  };

  # Add firewall exception for VirtualBox provider 
  networking.firewall.extraCommands = ''
    ip46tables -I INPUT 1 -i vboxnet+ -p tcp -m tcp --dport 2049 -j ACCEPT

    iptables        -A FORWARD                 -o   vboxnet+                    -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables        -A FORWARD     -i vboxnet+ -o \!vboxnet+ -s 192.168.51.0/24 -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    iptables        -A FORWARD     -i vboxnet+ -o \!vboxnet+ -s 192.168.51.0/24 -m conntrack --ctstate NEW                 -j ACCEPT
    iptables        -A FORWARD     -i vboxnet+ -o   vboxnet+ -s 192.168.51.0/24 -m conntrack --ctstate NEW                 -j ACCEPT
    iptables -t nat -A POSTROUTING             -o \!vboxnet+ -s 192.168.51.0/24                                            -j MASQUERADE
  '';

  networking.hosts = {
    "192.168.56.1" = [ "proxy.vbox.internal" "proxy.internal" ];
  };
}

{ config, lib, pkgs, ... }:

# this module allows for remote import of encrypted zfs pool on boot
# once logged-in as root, run "zpool import -a; zfs load-key -a && killall zfs"

{
  boot = {
    initrd = {
      network = {
        enable = true;
        ssh = {
          enable = true;
          port = 20222;
          hostKeys = [ /etc/secret/initrd/ssh/ssh_host_ed25519_key ];
          authorizedKeys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDbTid+LnC9bCaguMmIf1UUkR6gHPrkP6H6oQY3E4OqCK9TO0mPHLzYV9/eN6VuFBmDN+H/OGN4MclZjWbeBRUUkfZZ+MiD/eoGc0dJKS92bqMM5hwSllVPkKPQoMNZaEB8kGy48pmatbxMTAjK2r3gqCv5dZvC4MaxZ9U4cspBtosZSMvrTDZQy6imi5o75OHZhAtp9OL5+NA/AhdotXaoA+/VAmJPwYbhxcynVE8KLBZLMV/z/42G0LVhbaF55tIuOVgazSd61AIY5piKG80xEtjvduirC7mF89K135TqVEmobdpMhb+MpeFzLxoiGiD6XdfWznEze0rLQ8hAshnaTxSgGVAO8RF7Gnx3s9jeL3/Ww+5Oi6z3JV2uCGXR4M7G06zSos3HZxWmzS1D5HkjBsWkwAgVHlOiOAHLHiF5aLezt3zGzVzwc4wFGiIXmwhmhiZ+pKcZ4oQzLl0KmDnXpaerTLfRdGKmC0JMgKXEgFKQOFmDdIPoYsy2jcvljsfqfEs6LMyfwJ+T+N+Wza/6dJ8B5rE1jmaqXqtlRjQk115kF41+huqeIHWC4r63SopO1ahyW9iIIERt81nE9XlzTmcJyAX4axzX/1pWLw8XY1lguVNLndluBEVmtOXKAYKmipXYZd0LYJ0sCjTg6JSw0tQJI/wTNkjeM295fibzgQ==" ];
        };
      };
      kernelModules = [ "virtio-pci" "virtio-net" ];
    };
    kernelParams = [
      "ip=31.31.73.95::31.31.73.1:255.255.255.0:michowps:ens3:off:31.31.72.3:46.28.108.2:"
    ];
    kernelModules = [ "virtio-pci" "virtio-net" ];
  };
}

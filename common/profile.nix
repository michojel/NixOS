{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.profile;
  cfgLocal = config.local;
in
{
  options = {
    profile = {
      private = {
        enable = mkOption {
          type = types.bool;
          description = ''
            Enable system-wide installation of Nix Flakes. If you have your own way
            of Flakes enablement, set this to false.
            See https://nixos.wiki/wiki/Flakes for more information.
          '';
          default = true;
        };
      };

      work = {
        enable = mkEnableOption ''
          Enable work-related stuff on the host.
        '';
        primary = mkEnableOption ''
          Make this host primarily work-focused.
        '';
      };

      # TODO: rename to headless?
      server = {
        enable = mkEnableOption ''
          Headless server.
        '';
      };

    };

    local = {
      username = mkOption {
        type = types.nullOr types.str;
        description = ''
          Username of the user[id=1000]. Will be set based on the configured profiles.
        '';
      };
    };
  };

  config = rec {
    local.username = mkDefault (
      if (cfg.work.primary || (cfg.work.enable && !cfg.private.enable)) then
        "miminar"
      else
        "michojel"
    );

    assertions = [{
      assertion = !cfg.work.primary || cfg.work.enable;
      message = ''
        Disabled work profile cannot be made primary.
      '';
    }];

    users.extraUsers = {
      "${cfgLocal.username}" = {
        isNormalUser = true;
        uid = 1000;
        extraGroups = lib.mkAfter
          ([
            "fuse"
            "wheel"
          ]
          ++ (lib.optionals (!cfg.server.enable) [
            "audio"
            "cdrom"
            "docker"
            "i2c"
            "jackaudio"
            "libvirtd"
            "networkmanager"
            "openrazer"
            "plugdev"
            "utmp"
            "vboxusers"
            "video"
          ]));
        shell = pkgs.bashInteractive;
      };
    };

    users.extraGroups.i2c = {
      gid = 546;
    };
  };

  imports =
    let
      optImport = path: lib.optional (builtins.pathExists path) path;
    in
    [ ] ++ (concatLists (map optImport [
      # ideally, this would be gated by !cfg.server.enable, but that causes
      # infinite recursion
      /mnt/nixos/secrets/ethz/default.nix
      /mnt/nixos/secrets/external-filesystems.nix
    ]));
}

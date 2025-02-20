{ config, lib, pkgs, nodejs, ... }:
rec {
  nix = {
    settings = {
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "03:15";
      # Options given to nix-collect-garbage when the garbage collector is run automatically. 
      options = "--delete-older-than 21d";
    };
    # package = pkgs.nixFlakes;
  };

  boot = {
    tmp = {
      cleanOnBoot = true;
    };
    loader.timeout = 2;
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  # set temporarily to older release to work-around issue with systemd-timesyncd
  # - https://github.com/NixOS/nixpkgs/issues/64922
  system.stateVersion = "25.05";
  system.autoUpgrade.enable = true;
  system.autoUpgrade.channel = "https://nixos.org/channels/nixos-25.05";
  system.autoUpgrade.allowReboot = false;
  system.autoUpgrade.dates = "01:00";

  time.timeZone = "Europe/Prague";

  nixpkgs = {
    config = {
      allowUnfree = true;
    };
  };

  services = {
    logind = {
      lidSwitchExternalPower = "lock";
    };
    openssh = {
      enable = true;
    };

    udev.extraRules =
      ''
        ACTION=="add", KERNEL=="i2c-[0-9]*", GROUP="i2c"
        # ThinkPad Thunderbolt 3 Dock USB Audio
        # produces random key events (raising/lowering volume or (un)muting the audio output) -> ignore
        KERNEL=="event[0-9]*", SUBSYSTEM=="input", ATTRS{idVendor}=="17ef", ATTRS{idProduct}=="3083", ENV{LIBINPUT_IGNORE_DEVICE}="1"
      '';
    irqbalance.enable = true;
  };

  programs = {
    browserpass.enable = true;
  };

  systemd = {
    enableStrictShellChecks = true;
    tmpfiles.rules = [ "d /tmp 1777 root root 11d" ];
    services.nixos-upgrade = {
      preStart = ''
        set -euo pipefail
        export PATH="''$PATH:${pkgs.gitAndTools.git-annex}/bin"
        ${pkgs.sudo}/bin/sudo -u ${config.local.username} "${pkgs.bash}/bin/bash" \
          -c 'cd /home/${config.local.username}/wsp/nixos && ${pkgs.gitAndTools.git}/bin/git pull https://github.com/michojel/NixOS master ||:'
        ${pkgs.nix}/bin/nix-channel --update nixos-unstable
      '';
      postStart =
        let
          sudoExec =
            cmd: lib.concatStringsSep " " [
              ''/run/wrappers/bin/sudo -u ${config.local.username}''
              ''"${pkgs.bash}/bin/bash" --login -c 'cd $HOME &&''
              cmd
              "'"
            ];
          commands = [
            ''nix-channel --update && nix-env --upgrade "*"''
            ''home-manager switch -b bak''
            ''nix-index''
          ];
        in
        lib.concatStringsSep "\n" (lib.concatLists [ [ "set -x" ] (map sudoExec commands) ]);
      requires = pkgs.lib.mkAfter [ "network-online.target" ];
      after = pkgs.lib.mkAfter [ "network-online.target" ];
    };

    services.systemd-rfkill = {
      wantedBy = [ "default.target" ];
    };
  };

  documentation = {
    dev.enable = true;
    doc.enable = true;
    info.enable = true;
    man = {
      enable = true;
      generateCaches = true;
    };
    nixos.includeAllModules = true;
  };

  hardware = {
    enableRedistributableFirmware = true;
    cpu.intel.updateMicrocode = true;
  };

  # causes hangs
  #powerManagement.powertop.enable = true;

  environment.extraOutputsToInstall = [ "doc" "info" "devdoc" "man" ];
}

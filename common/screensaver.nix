{ config, lib, pkgs
, xkbLayout  ? "vok,ru"
, xkbVariant ? ","
, xkbOption  ? "grp:shift_caps_toggle,terminate:ctrl_alt_bksp"
, ... }:

let
   keyboard-layout = import ./keyboard-layout.nix {
     inherit xkbLayout;
     inherit xkbVariant;
     inherit xkbOption;
   };

   i3lock-wrapper = import ./i3lock-wrapper.nix {
     keyboard-layout = keyboard-layout;
   };

  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };

  killer = pkgs.writeTextFile {
    name = "xautolock-killer";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      exec "${unstable.lxqt.lxqt-session}/bin/lxqt-leave" --logout
    '';
  };

  notifier = pkgs.writeTextFile {
    name = "xautolock-notifier";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      exec "${pkgs.libnotify}/bin/notify-send" -u low 'Screen lock' "I'm going to lock the screen in 15 seconds ..."
    '';
  };
in {
  services = {
    xserver = {
      xautolock = with pkgs; {
        enable = true;
        time = 10;
        locker = "${i3lock-wrapper}/bin/i3lock";
        killer = "${killer}";
        enableNotifier = true;
        notify = 15;
        notifier = "${notifier}";
      };
    };
  };

  systemd = {
    user.services = {
      xautolock = {
        serviceConfig = {
          ExecStartPre = "-${pkgs.xautolock}/bin/xautolock -exit";
          ExecStop = "${pkgs.xautolock}/bin/xautolock -exit";
          RestartSec = 2;
        };
      };
    };
  };

  nixpkgs.config.packageOverrides = pkgs: with pkgs; rec {
    i3lock-wrapper = i3lock-wrapper;
    keyboard-layout = keyboard-layout;
  };

  environment.systemPackages = with pkgs; [
    i3lock-color
    i3lock-wrapper
    keyboard-layout
  ];
}

{ config, lib, pkgs, ... }:

let
  setpsgov = "${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g powersave";
  setpfgov = "${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g performance";

  ssetpsgov = "/run/wrappers/bin/sudo ${setpsgov}";
  ssetpfgov = "/run/wrappers/bin/sudo ${setpfgov}";

  mk-jack-the-default-sink = pkgs.writeTextFile {
    name = "mk-jack-the-default-sink.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      set -x
      
      ${pkgs.pulseaudioFull}/bin/pactl set-default-sink jack_out ||:

      sinkID="$(${pkgs.pulseaudioFull}/bin/pactl list sinks | ${pkgs.gawk}/bin/awk 'match($0, /^Sink #([0-9]+)/, a) {
          sink=a[1]
      }
      /Description:.*[Jj]ack/ {
          print sink
          exit
      }')"

      if [[ -z "${sinkID:-}" ]]; then
          printf 'Failed to determine Jack'"'"'s sink ID!\n' >&2
          exit 1
      fi

      ${pkgs.pulseaudioFull}/bin/pactl list sink-inputs | ${pkgs.gawk}/bin/awk 'match($0, /^Sink Input #?([0-9]+)/, sia) {
          si=sia[1]
      }
      match($0, /^[[:space:]]+Sink:[[:space:]]+#?([0-9]+)/, sa) {
          if (sa[1] != '"$sinkID"') {
              print si
          }
      }' | xargs -t -r -n 1 -i ${pkgs.pulseaudioFull}/bin/pactl move-sink-input '{}' "$sinkID"
    '';
  };

  jack-start-pre = pkgs.writeTextFile {
    name = "jack-start-pre.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      set -x

      function useFirewireDevice() {
          ${pkgs.jack2Latest}/bin/jack_control ds  firewire
          ${pkgs.jack2Latest}/bin/jack_control dps rate    192000
          ${pkgs.jack2Latest}/bin/jack_control dps verbose 3
      }
      
      if ${pkgs.procps}/bin/pgrep -u "$USER" jackdbus >/dev/null 2>&1; then
          ${pkgs.psmisc}/bin/killall -9 jackdbus ||:
          sleep 1
      fi

      if [[ "$(${pkgs.findutils}/bin/find /dev -maxdepth 1 -name 'fw*' -type c -group audio)" ]]; then
          useFirewireDevice
      else
          ${pkgs.ffado.bin}/bin/ffado-test BusReset  ||:
          ${pkgs.jack2Latest}/bin/jack_control ds dummy
          sleep 1
      fi

      if [[ "$(${pkgs.findutils}/bin/find /dev -maxdepth 1 -name 'fw*' -type c -group audio)" ]]; then
          useFirewireDevice
      else
          exit 0
      fi

      ${ssetpfgov} ||:

      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1 && \
              ${pkgs.pulseaudioFull}/bin/pactl stat >/dev/null 2>&1;
      then
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jack-sink       ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jack-source     ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jackdbus-detect ||:
          ${pkgs.pulseaudioFull}/bin/pacmd suspend 1
          ${pkgs.pulseaudioFull}/bin/pactl load-module module-null-sink         ||:
          ${pkgs.pulseaudioFull}/bin/pactl set-default-sink null                ||:
      fi
    '';
  };

  jack-start = pkgs.writeTextFile {
    name = "jack-start.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      set -x

      function fallbackToAlsa() {
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-null-sink ||:
          ${pkgs.pulseaudioFull}/bin/pacmd suspend 0
          ${ssetpsgov}
      }

      if ${pkgs.jack2Latest}/bin/jack_control dg | grep -q dummy; then
          fallbackToAlsa
          exit 0
      fi
      ${pkgs.jack2Latest}/bin/jack_control start

      sleep 1

      for ((i=0; i < 15; i++)); do
          if ${pkgs.jack2Full}/bin/jack_control status | \
                ${pkgs.gnugrep}/bin/grep -q started;
          then
              break
          fi
          sleep 0.3
      done

      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1 && \
              ${pkgs.pulseaudioFull}/bin/pactl stat >/dev/null 2>&1;
      then
          ${pkgs.pulseaudioFull}/bin/pactl load-module module-jackdbus-detect channels=2 ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-null-sink ||:
          if ${pkgs.pulseaudioFull}/bin/pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out';
          then
              ${mk-jack-the-default-sink} || :
          else
            fallbackToAlsa
          fi
      fi
    '';
  };

  jack-stop = pkgs.writeTextFile {
    name = "jack-stop.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      set -x
      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1 && \
              ${pkgs.pulseaudioFull}/bin/pactl stat >/dev/null 2>&1;
      then
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jack-sink       ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jack-source     ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-jackdbus-detect ||:
          ${pkgs.pulseaudioFull}/bin/pactl unload-module module-null-sink       ||:
          ${pkgs.pulseaudioFull}/bin/pacmd suspend 0
      fi
      ${ssetpsgov} ||:
      ${pkgs.jack2Latest}/bin/jack_control stop
    '';
  };

  pulseaudio-start-pre = pkgs.writeTextFile {
    name = "pulseaudio-start-pre.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'

      set -x
      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1; then
          if pactl stat >/dev/null 2>&1; then
              ${pkgs.pulseaudioFull}/bin/pactl exit ||:
          fi
          ${pkgs.psmisc}/bin/killall -u "$USER" -9 pulseaudio  ||:
      fi
    '';
  };

  pulseaudio-start-post = pkgs.writeTextFile {
    name = "pulseaudio-start-post.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      
      set -x
      for ((i=0; i < 10; i++)); do
          if ${pkgs.jack2Full}/bin/jack_control status | \
                ${pkgs.gnugrep}/bin/grep -q started;
          then
              break
          fi
          sleep 0.5
      done

      if ! ${pkgs.jack2Latest}/bin/jack_control status | grep -q started; then
          exit 0
      fi

      if ${pkgs.jack2Latest}/bin/jack_control dg | grep -q dummy; then
          exit 0
      fi

      for ((i=0; i < 10; i++); do
          if ${pkgs.pulseaudioFull}/bin/pactl status && \
                ${pkgs.pulseaudioFull}/bin/pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out';
          then
              break
          fi
          sleep 0.5
      done

      if ${pkgs.pulseaudioFull}/bin/pactl status && \
            ${pkgs.pulseaudioFull}/bin/pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out';
      then
        ${mk-jack-the-default-sink} || :
        ${ssetpfgov}
      fi
    '';

  };

  # TODO: need to disable jackdbus-detect module on pulseaudio's startup
  #   - for some reason, pulseaudio cannot start with jackdbus-detect module when jackdbus is running
  #     this prevents from successful graphical session startup
  default-pa = pkgs.writeTextFile {
    name = "default.pa";
    # TODO: read the defaults from the package and just comment out jackdbus
    text = ''
      .fail
        
      ### Automatically restore the volume of streams and devices
      load-module module-device-restore
      load-module module-stream-restore
      load-module module-card-restore
        
      ### Automatically augment property information from .desktop files
      ### stored in /usr/share/application
      load-module module-augment-properties
        
      ### Should be after module-*-restore but before module-*-detect
      load-module module-switch-on-port-available
        
      ### Automatically load driver modules depending on the hardware available
      .ifexists module-udev-detect.so
      load-module module-udev-detect
      .else
      ### Use the static hardware detection module (for systems that lack udev support)
      load-module module-detect
      .endif
        
      ### Automatically connect sink and source if JACK server is present
      #.ifexists module-jackdbus-detect.so
      #.nofail
      #load-module module-jackdbus-detect channels=2
      #.fail
      #.endif
        
      ### Automatically load driver modules for Bluetooth hardware
      .ifexists module-bluetooth-policy.so
      load-module module-bluetooth-policy
      .endif
        
      .ifexists module-bluetooth-discover.so
      load-module module-bluetooth-discover
      .endif
        
      ### Load several protocols
      .ifexists module-esound-protocol-unix.so
      load-module module-esound-protocol-unix
      .endif
      load-module module-native-protocol-unix
        
      ### Network access (may be configured with paprefs, so leave this commented
      ### here if you plan to use paprefs)
      #load-module module-esound-protocol-tcp
      #load-module module-native-protocol-tcp
      #load-module module-zeroconf-publish
        
      ### Load the RTP receiver module (also configured via paprefs, see above)
      #load-module module-rtp-recv
        
      ### Load the RTP sender module (also configured via paprefs, see above)
      #load-module module-null-sink sink_name=rtp format=s16be channels=2 rate=44100 sink_properties="device.description='RTP Multicast Sink'"
      #load-module module-rtp-send source=rtp.monitor
        
      ### Load additional modules from GSettings. This can be configured with the paprefs tool.
      ### Please keep in mind that the modules configured by paprefs might conflict with manually
      ### loaded modules.
      .ifexists module-gsettings.so
      .nofail
      load-module module-gsettings
      .fail
      .endif
        
        
      ### Automatically restore the default sink/source when changed by the user
      ### during runtime
      ### NOTE: This should be loaded as early as possible so that subsequent modules
      ### that look up the default sink/source get the right value
      load-module module-default-device-restore
        
      ### Automatically move streams to the default sink if the sink they are
      ### connected to dies, similar for sources
      load-module module-rescue-streams
        
      ### Make sure we always have a sink around, even if it is a null sink.
      load-module module-always-sink
        
      ### Honour intended role device property
      load-module module-intended-roles
        
      ### Automatically suspend sinks/sources that become idle for too long
      load-module module-suspend-on-idle
        
      ### If autoexit on idle is enabled we want to make sure we only quit
      ### when no local session needs us anymore.
      .ifexists module-console-kit.so
      load-module module-console-kit
      .endif
      .ifexists module-systemd-login.so
      load-module module-systemd-login
      .endif
        
      ### Enable positioned event sounds
      load-module module-position-event-sounds
        
      ### Cork music/video streams when a phone stream is active
      load-module module-role-cork
        
      ### Modules to allow autoloading of filters (such as echo cancellation)
      ### on demand. module-filter-heuristics tries to determine what filters
      ### make sense, and module-filter-apply does the heavy-lifting of
      ### loading modules and rerouting streams.
      load-module module-filter-heuristics
      load-module module-filter-apply
        
      ### Make some devices default
      #set-default-sink output
      #set-default-source input
    '';
  };


in
rec {

  imports = [
    /mnt/nixos/musnix
  ];

  musnix = {
    enable = true;
    ffado.enable = true;
    # TODO: enable
    #    kernel = {
    #      realtime = true;
    #      optimize = true;
    #      #packages = pkgs.linuxPackages_4_18_rt;
    #      packages = pkgs.linuxPackages_latest_rt;
    #    };
  };

  boot = {
    kernelModules = [ "snd-seq" "snd-rawmidi" "firewire_core" "firewire_ohci" ];

    # TODO: switch to musnix.kernel when working for the current linux
    kernelPackages = let
      rtKernel = pkgs.linuxPackagesFor (
        pkgs.linux.override {
          extraConfig = ''
            #CPU_FREQ n
            #DEFAULT_IOSCHED deadline
            #TREE_RCU_TRACE n
            DEFAULT_DEADLINE y
            DEFAULT_IOSCHED deadline
            HPET_TIMER y
            IOSCHED_DEADLINE y
            PREEMPT_RT_FULL? y
            PREEMPT_VOLUNTARY n
            PREEMPT y
          '';
          #ignoreConfigErrors = true;
          #kernelPreferBuiltin = true;
          enableParallelBuilding = true;
        }
      );
    in
      rtKernel;
  };

  services = {
    udev = {
      extraRules = ''
        # QuataFire 610
        ACTION == "add", SUBSYSTEM=="firewire", ATTR{units}=="0x00a02d:0x010001", GROUP="audio"
      '';
    };

    jack = {
      alsa = {
        enable = false;
        #support32Bit = true;
      };
      jackd = {
        enable = false;
      };
      loopback.enable = false;
    };
  };

  systemd = {
    user.services = {
      jack = {
        before = [ "sound.target" ];
        requires = [ "dbus.socket" ];
        after = [ "usb-reset.service" ];
        wantedBy = [ "graphical-session.target" "sound.target" ];
        description = "JACK Audio Connection Kit DBus";
        serviceConfig = {
          Type = "dbus";
          BusName = "org.jackaudio.service";
          ExecStartPre = "-${jack-start-pre}";
          ExecStart = "${jack-start}";
          ExecStop = "${jack-stop}";
          ExecStopPost = "-${pkgs.procps}/bin/pkill -9 jackdbus";
          RemainAfterExit = true;
          LimitRTPRIO = 99;
          LimitMEMLOCK = "infinity";
          LimitRTTIME = "infinity";
        };
        path = [ "${pkgs.jack2Latest}" ];
        restartIfChanged = true;
      };

      #pulseaudio.partOf = [ "jack.service" ];
      pulseaudio.serviceConfig = {
        ExecStartPre = "${pulseaudio-start-pre}";
        ExecStartPost = "${pulseaudio-start-post}";
      };
    };
  };

  environment.interactiveShellInit = ''
    alias jackctl='jack_control'
  '';

  environment.systemPackages = with pkgs; [
    # audio
    ardour
    audacity
    bristol
    dssi
    ffado
    guitarix
    jack2Latest
    jamin
    pavucontrol
    qjackctl
    rakarrack
    ssr
  ];

  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      ffado = pkgs.libsForQt5.callPackage ./ffado {
        inherit (pkgs.linuxPackages) kernel;
      };
      libffado = ffado;

      jack2Latest = pkgs.callPackage ./jackaudio {
        libffado = libffado;
        libopus = pkgs.libopus.override { withCustomModes = true; };
        inherit (pkgs) dbus;
        inherit (pkgs) alsaLib;
      };
      libjack2Latest = jack2Latest.override {
        prefix = "lib";
      };

      pulseaudioFull = pkgs.pulseaudioFull.override {
        libjack2 = libjack2Latest;
      };

      pulseaudio = pkgs.pulseaudio.override {
        libjack2 = libjack2Latest;
      };

      qjackctl = pkgs.qjackctl.override {
        libjack2 = libjack2Latest;
      };

      vlc = pkgs.vlc.override {
        jackSupport = true;
        libjack2 = libjack2Latest;
      };
    };
  };

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = false;
      configFile = "${default-pa}";
    };
  };

  security.sudo.extraRules = [
    {
      commands = [
        { command = setpsgov; options = [ "NOPASSWD" ]; }
        { command = setpfgov; options = [ "NOPASSWD" ]; }
      ];
      groups = [ "wheel" ];
    }
  ];
}

{ config
, lib
, pkgs
, ...
}:

let

  #firewire_sample_rate = 192000;
  #firewire_sample_rate = null;
  # guitarix does not support higher sample rate than 96000
  firewire_sample_rate = 96000;
  ffado_loglevel = null; # integer (0-10)
  jack_rtprio = 64;
  # let the engine use the defaults
  jack_verbose = null;  # integer (0-10)
  jack_portmax = null;  # integer

  jacksetp = cmdPrefix: paramName: value: "${
  if paramName == null
  then "jackctl ${cmdPrefix}pr ${paramName}"
  else "jackctl ${cmdPrefix}ps ${paramName} ${toString value}"}";

  setpsgov = "${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g powersave";
  setpfgov = "${pkgs.linuxPackages.cpupower}/bin/cpupower frequency-set -g performance";

  sudoWrap = cmd: "SUDO_ASKPASS=${pkgs.coreutils}/bin/yes /run/wrappers/bin/sudo " + cmd;
  ssetpsgov = "${sudoWrap setpsgov}";
  ssetpfgov = "${sudoWrap setpfgov}";

  # https://nixos.wiki/wiki/Snippets#Adding_compiler_flags_to_a_package
  optimizeWithFlag = pkg: flag:
    pkg.overrideAttrs (
      attrs: {
        NIX_CFLAGS_COMPILE = (attrs.NIX_CFLAGS_COMPILE or "") + " ${flag}";
      }
    );
  # This function can further be used to define the following helpers:
  optimizeWithFlags = pkg: flags: pkgs.lib.foldl' (pkg: flag: optimizeWithFlag pkg flag) pkg flags;
  optimizeForThisHost = pkg: optimizeWithFlags pkg [ "-O3" "-march=native" "-fPIC" ];
  withDebuggingCompiled = pkg: optimizeWithFlag pkg "-DDEBUG";

  firewire-audio-common = pkgs.writeTextFile {
    name = "firewire-audio-common.sh";
    executable = false;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'

      function init() {
          export PATH="${pkgs.pulseaudioFull}/bin:$PATH"
      }
      init

      function jackctl() {
          ${pkgs.jack2Latest}/bin/jack_control "$@"
      }

      function unloadJackModules() {
          local module
          for module in module-jack{-sink,-source,dbus-detect}; do
              pactl unload-module "$module" ||:
          done
      }

      function getFirewireDevices() {
          ${pkgs.findutils}/bin/find /dev -maxdepth 1 -name 'fw*' -type c -group audio
      }

      function waitUntilJackReady() {
        local minAttemptsReady="''${1:-5}"
        local readyCounter="$minAttemptsReady"
        local i 
        for ((i=0; i - $minAttemptsReady + readyCounter < 15; i++)); do
            local status="$(jackctl status | tail -n 1)"
            if grep -q started <<<"''${status:-}"; then
                if [[ "$readyCounter" -lt 1 ]]; then
                    return 0
                fi
                readyCounter="$(($readyCounter - 1))"
            else
                readyCounter="$minAttemptsReady"
            fi
            printf 'Waiting for Jack to become ready (status: %s,' >&2 "''${status:-unknown}"
            printf ' attempts left: %s,'                           >&2 "$((15 - $i - 1))"
            printf ' successful attempts left: %s,'                >&2 "$readyCounter"
            printf ' seconds left: %ss)...\n'                      >&2 "$(((15 - $i - 1)/2))"
            sleep 0.5
        done

        if ! jackctl status | grep -q started; then
            printf 'Jack has not come up!\n' >&2
            return 1
        fi
      }

      function isPulseAudioRunning() {
        ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1 && \
              pactl stat >/dev/null;
      }
    '';
  };

  mk-jack-the-default-sink = pkgs.writeTextFile {
    name = "mk-jack-the-default-sink.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      source "${firewire-audio-common}"
      init

      printf 'Configuring jack_out sink as the default.\n' >&2
      pactl set-default-sink jack_out ||:

      sinkID="$(pactl list sinks | ${pkgs.gawk}/bin/awk 'match($0, /^Sink #([0-9]+)/, a) {
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

      pactl list sink-inputs | ${pkgs.gawk}/bin/awk 'match($0, /^Sink Input #?([0-9]+)/, sia) {
          si=sia[1]
      }
      match($0, /^[[:space:]]+Sink:[[:space:]]+#?([0-9]+)/, sa) {
          if (sa[1] != '"$sinkID"') {
              print si
          }
      }' | ${pkgs.findutils}/bin/xargs -t -r -n 1 -i \
            pactl move-sink-input '{}' "$sinkID"
    '';
  };

  jack-start-pre = pkgs.writeTextFile {
    name = "jack-start-pre.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      source "${firewire-audio-common}"
      init

      set -x

      function useFirewireDevice() {
          printf 'Configuring Jack to use firewire device.\n' >&2
          jackctl ds  firewire
          jackctl eps realtime true
          ${jacksetp "d" "verbose" ffado_loglevel}
          ${jacksetp "d" "rate" firewire_sample_rate}
          ${jacksetp "e" "realtime-priority" jack_rtprio}
          ${jacksetp "e" "verbose" jack_verbose}
          ${jacksetp "e" "port-max" jack_portmax}
      }

      if ${pkgs.procps}/bin/pgrep -u "$USER" jackdbus >/dev/null 2>&1; then
          ${pkgs.psmisc}/bin/killall -9 jackdbus ||:
          sleep 1
      fi

      toLoad=( $(printf '%s\n' firewire_{core,ohci} | \
                 grep -v -F -f <(${pkgs.kmod}/bin/lsmod | \
                 ${pkgs.gawk}/bin/awk '{print $1}') ||:) )
      if [[ "''${#toLoad[@]}" -gt 0 ]]; then
          for module in "''${toLoad[@]}"; do
              printf 'Loading module %s\n' "$module" >&2
              ${sudoWrap (pkgs.kmod + "/bin/modprobe $module")} ||:
          done
      fi

      if [[ "$(getFirewireDevices)" ]]; then
          useFirewireDevice
      else
          printf 'No firewire device detected. Trying to reset the bus...\n' >&2
          ${pkgs.ffado.bin}/bin/ffado-test BusReset  ||:
          jackctl ds dummy
          sleep 1
          if [[ "$(getFirewireDevices)" ]]; then
              useFirewireDevice
          else
              printf 'No firewire device detected.\n' >&2
              exit 0
          fi
      fi

      printf 'Switching CPU Frequency Governor to "performance"...\n' >&2
      ${ssetpfgov} ||:

      if isPulseAudioRunning; then
          printf 'Unloading Jack modules from PulseAudio and temporarily' >&2
          printf ' switching to the null sink.\n' >&2
          unloadJackModules
          pacmd suspend 1
          pactl load-module module-null-sink         ||:
          pactl set-default-sink null                ||:
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
      source "${firewire-audio-common}"
      init

      function fallbackToAlsa() {
          printf 'Falling back to alsa PulseAudio module...\n' >&2
          pactl unload-module module-null-sink ||:
          pacmd suspend 0
          printf 'Switching CPU Frequency Governor to "powersave"...\n' >&2
          ${ssetpsgov}
      }

      if jackctl dg | grep -q dummy; then
          fallbackToAlsa
          exit 0
      fi
      printf 'Starting Jack on DBus...\n' >&2
      jackctl start

      sleep 1

      if ! waitUntilJackReady; then
          printf 'Jack did not come up! Skipping PulseAudio module loading.\n' >&2
          exit 1
      fi

      if isPulseAudioRunning; then
          printf 'Loading Jack modules in PulseAudio...\n' >&2
          pactl load-module module-jackdbus-detect channels=2 ||:
          pactl unload-module module-null-sink ||:
          if pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out'; then
              printf 'Setting Jack sink as the default in PulseAudio...\n' >&2
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
      source "${firewire-audio-common}"
      init

      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1 && \
              pactl stat >/dev/null 2>&1;
      then
          printf 'Unloading Jack modules from PulseAudio...\n' >&2
          unloadJackModules
          pactl unload-module module-null-sink       ||:
          pacmd suspend 0
      fi
      printf 'Switching CPU Frequency Governor to "powersave"...\n' >&2
      ${ssetpsgov} ||:
      printf 'Stopping Jack server...\n' >&2
      jackctl stop
    '';
  };

  pulseaudio-start-pre = pkgs.writeTextFile {
    name = "pulseaudio-start-pre.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'
      source "${firewire-audio-common}"
      init

      if ${pkgs.procps}/bin/pgrep -u "$USER" pulseaudio >/dev/null 2>&1; then
          if pactl stat >/dev/null 2>&1; then
              pactl exit ||:
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
      source "${firewire-audio-common}"
      init
      
      if ! waitUntilJackReady; then
          exit 0
      fi

      if jackctl dg | grep -q dummy; then
          printf 'Jack is configured with dummy device, skipping its setup...\n' >&2
          exit 0
      fi

      for ((i=0; i < 10; i++); do
          if pactl stat && pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out'; then
              break
          fi
          printf 'Waiting for Jack sink to get loaded...\n' >&2
          sleep 0.5
      done

      if pactl stat && pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out'; then
        ${mk-jack-the-default-sink} || :
        printf 'Switching CPU Frequency Governor to "performance"...\n' >&2
        ${ssetpfgov}
      fi
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
    kernelPackages = pkgs.linuxPackages;
  };

  services = {
    udev = {
      extraRules = ''
        # QuataFire 610
        ACTION == "add", SUBSYSTEM=="firewire", ATTR{units}=="0x00a02d:0x010001", GROUP="audio"
      '';
    };

    # Jack is used over DBus.
    # It controls solely one external firewire device.
    # PulseAudio stands between Jack and alsa
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
          # TODO: find out, how to run it under audio group
          #Group = "audio";
        };
        path = [ "${pkgs.jack2Latest}" ];
        restartIfChanged = true;
      };

      #pulseaudio.partOf = [ "jack.service" ];
      pulseaudio = {
        serviceConfig = {
          ExecStartPre = "${pulseaudio-start-pre}";
          ExecStartPost = "${pulseaudio-start-post}";
          LimitRTPRIO = 99;
          LimitMEMLOCK = "infinity";
          LimitRTTIME = "infinity";
          LimitNICE = "-20";
        };
      };
    };
  };

  environment.interactiveShellInit = ''
    alias jackctl='jack_control'
  '';

  environment.systemPackages = with pkgs; [
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

  nixpkgs = rec {
    overlays = lib.singleton (
      lib.const (
        super: {
          # TODO: switch to musnix.kernel when working for the current linux
          linuxPackages = super.linuxPackagesFor (
            let
              ksuper = super.linuxPackages.kernel;
            in
              let
                rtKernel = ksuper.override {
                  name = ksuper.name + "-rt";
                  extraConfig = ''
                    CPU_FREQ? n
                    DEFAULT_DEADLINE y
                    DEFAULT_IOSCHED? deadline
                    HPET_TIMER y
                    IOSCHED_DEADLINE y
                    PREEMPT_RT_FULL? y
                    PREEMPT_VOLUNTARY n
                    PREEMPT y
                    RT_GROUP_SCHED? n
                    TREE_RCU_TRACE? n
                  '';
                  enableParallelBuilding = true;
                };
              in
                rtKernel
          );
        }
      )
    );

    config = {
      packageOverrides = pkgs: rec {
        ffado = pkgs.libsForQt5.callPackage ./ffado {
          inherit (pkgs.linuxPackages) kernel;
        };
        libffado = ffado;

        # not overriding (lib)jack2 to avoid to many dependency rebuilds
        jack2Latest = optimizeForThisHost (
          pkgs.callPackage ./jackaudio {
            libffado = libffado;
            libopus = pkgs.libopus.override { withCustomModes = true; };
            inherit (pkgs) dbus;
            inherit (pkgs) alsaLib;
          }
        );
        libjack2Latest = optimizeForThisHost (
          jack2Latest.override {
            prefix = "lib";
          }
        );

        pulseaudioFull = optimizeForThisHost (
          pkgs.pulseaudioFull.override {
            libjack2 = libjack2Latest;
          }
        );

        # optimizing this would result in too many rebuilds
        pulseaudio = pkgs.pulseaudio.override {
          libjack2 = libjack2Latest;
        };

        qjackctl = pkgs.qjackctl.override {
          libjack2 = libjack2Latest;
        };

        vlc = optimizeForThisHost (
          pkgs.vlc.override {
            jackSupport = true;
            libjack2 = libjack2Latest;
          }
        );

        guitarix = optimizeForThisHost (
          pkgs.guitarix.override {
            libjack2 = libjack2Latest;
            optimizationSupport = true;
          }
        );

        rakarrack = optimizeForThisHost (
          pkgs.rakarrack.override {
            libjack2 = libjack2Latest;
          }
        );

        ssr = optimizeForThisHost (
          pkgs.ssr.override {
            libjack2 = libjack2Latest;
          }
        );
      };
    };
  };

  hardware = {
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      #support32Bit = false;

      # for some reason, pulseaudio cannot start with jackdbus-detect module when jackdbus is running
      # this prevents from successful graphical session startup
      configFile = pkgs.runCommand "default.pa" {} ''
        ${pkgs.gawk}/bin/awk 'BEGIN {
            commentout=0
          } /^\.ifexists module-jackdbus-detect/ {
             commentout=1
          } /.*/ {
              if (commentout == 1) {
                  print "# "$0;
                  if (/^\.endif/) {
                      commentout=0
                  }
              } else {
                  print $0
              }
          } END {
              print ".ifexists module-echo-cancel.so";
              print "load-module module-echo-cancel.so";
              print ".endif";
          }' ${pkgs.pulseaudioFull}/etc/pulse/default.pa > $out
      '';

      daemon = {
        config = {
          realtime-scheduling = "yes";
          log-level = "info";
          realtime-priority = 32;
          high-priority = "yes";
          nice-level = "-15";
        };
      };
    };
  };

  security.sudo.extraRules = [
    {
      commands = [
        { command = setpsgov; options = [ "NOPASSWD" ]; }
        { command = setpfgov; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.kmod}/bin/modprobe firewire_core"; options = [ "NOPASSWD" ]; }
        { command = "${pkgs.kmod}/bin/modprobe firewire_ohci"; options = [ "NOPASSWD" ]; }
      ];
      groups = [ "audio" "wheel" ];
    }
  ];

  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
}

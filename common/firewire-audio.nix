{ config
, lib
, pkgs
, ...
}:

# TODO: avoid infinite recursion
#assert (
#  lib.assertMsg (
#    lib.any ({ e }: e == "nvidia") config.services.xserver.videoDrivers
#  ) "Nvidia driver does not support preemptive real-time kernel (PREEMPT_RT=y)!"
#);

let

  #firewireSampleRate = 192000;
  #firewireSampleRate = null;
  # guitarix does not support higher sample rate than 96000
  firewireSampleRate = 96000;
  ffadoLogLevel = null; # integer (0-10)
  jackRTPrio = 64;
  # let the engine use the defaults
  jackVerbose = null; # integer (0-10)
  jackPortMax = null; # integer
  truePreemptRT = false;
  recompileKernel = false;

  jacksetp = cmdPrefix: paramName: value: "${
  if paramName == null
  then "jackctl ${cmdPrefix}pr ${paramName}"
  else "jackctl ${cmdPrefix}ps ${paramName} ${toString value}"}";

  setpsgov = "${config.security.wrapperDir}/cpupower frequency-set -g powersave";
  setpfgov = "${config.security.wrapperDir}/cpupower frequency-set -g performance";

  # Copied from: https://nixos.wiki/wiki/Snippets#Adding_compiler_flags_to_a_package
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

  load-firewire-modules = pkgs.writeTextFile {
    name = "load-firewire-modules.sh";
    executable = true;
    text = ''
      #!${pkgs.bash}/bin/bash
      set -euo pipefail
      IFS=$'\n\t'

      # TODO: when loaded by this script, wait a few moments until /dev/fw*
      #       devices get loaded
      ${pkgs.kmod}/bin/modprobe firewire_core ||:
      ${pkgs.kmod}/bin/modprobe firewire_ohci ||:
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

      function useFirewireDevice() {
          printf 'Configuring Jack to use firewire device.\n' >&2
          jackctl ds  firewire
          jackctl eps realtime true
          ${jacksetp "d" "verbose" ffadoLogLevel}
          ${jacksetp "d" "rate" firewireSampleRate}
          ${jacksetp "e" "realtime-priority" jackRTPrio}
          ${jacksetp "e" "verbose" jackVerbose}
          ${jacksetp "e" "port-max" jackPortMax}
      }

      if ${pkgs.procps}/bin/pgrep -u "$USER" jackdbus >/dev/null 2>&1; then
          ${pkgs.psmisc}/bin/killall -u "$USER" -9 jackdbus ||:
          sleep 1
      fi

      "${config.security.wrapperDir}/load-firewire-modules"

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
      ${setpfgov} ||:

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
          ${setpsgov}
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
          fallbackToAlsa
          exit 1
      fi

      if isPulseAudioRunning; then
          printf 'Loading Jack modules in PulseAudio...\n' >&2
          pactl load-module module-jackdbus-detect channels=2 ||:
          pactl unload-module module-null-sink ||:
          if pactl list sinks | grep -q 'Name:[[:space:]]\+jack_out'; then
              printf 'Setting Jack sink as the default in PulseAudio...\n' >&2
              ${mk-jack-the-default-sink} || :
              pacmd suspend 0
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
      ${setpsgov} ||:
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
        ${setpfgov}
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
      extraRules = let
        mkFirewireRule = units: vendor: model: (
          builtins.concatStringsSep ", " [
            ''ACTION=="add"''
            ''SUBSYSTEM=="firewire"''
            ''ATTR{units}=="${units}"''
            ''ATTR{vendor}=="${vendor}"''
            ''ATTR{model}=="${model}"''
            ''GROUP="audio"''
            ''TAG+="systemd"''
            ''ENV{SYSTEMD_USER_WANTS}="jack.service"''
          ]
        );
      in
        ''
          # QuataFire 610
          ${mkFirewireRule "0x00a02d:0x010001" "0x000f1b" "0x010064"}
          # Edirol FA-101
          ${mkFirewireRule "0x00a02d:0x010001" "0x0040ab" "0x010048"}
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
        requires = [ "dbus.socket" "pulseaudio.service" ];
        after = [ "usb-reset.service" "pulseaudio.service" ];
        wantedBy = [ "graphical-session.target" "sound.target" ];
        description = "JACK Audio Connection Kit DBus";
        serviceConfig = {
          Type = "dbus";
          BusName = "org.jackaudio.service";
          ExecStartPre = "-${jack-start-pre}";
          ExecStart = "${jack-start}";
          ExecStop = "${jack-stop}";
          ExecStopPost = "-${pkgs.procps}/bin/pkill -u %u -9 jackdbus";
          RemainAfterExit = true;
          LimitRTPRIO = "infinity";
          LimitMEMLOCK = "infinity";
          LimitRTTIME = "infinity";
          LimitNICE = "-20";
        };
        path = [ "${pkgs.jack2Latest}" ];
        restartIfChanged = true;
      };

      pulseaudio = {
        serviceConfig = {
          # TODO: find out how to override just the executable path
          #  ExecStart = lib.intersperse " " (
          #    lib.concat
          #      [ "${config.security.wrapperDir}/pulseaudio" ]
          #      (
          #        lib.tail (
          #          lib.splitString " " "${config.systemd.user.services.pulseaudio.serviceConfig.ExecStart}"
          #        )
          #      )
          #  );

          # the first empty string clears the default value
          ExecStart = [ "" "${config.security.wrapperDir}/pulseaudio --daemonize=no" ];
          ExecStartPre = "${pulseaudio-start-pre}";
          ExecStartPost = "${pulseaudio-start-post}";
          LimitRTPRIO = "infinity";
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
    overlays = if recompileKernel then
      lib.singleton (
        lib.const (
          super: {
            # TODO: switch to musnix.kernel when working for the current linux on
            # stable NixOS branch
            linuxPackages = super.linuxPackagesFor (
              let
                ksuper = super.linuxPackages.kernel;
                kversion = if truePreemptRT then "4.19.106" else ksuper.version;
                pversion = "rt45";
                fullVersion = if truePreemptRT then kversion + "-" + pversion else kversion;
              in
                let
                  rtKernel = ksuper.override {
                    name = ksuper.name + fullVersion;
                    extraConfig = ''
                      CPU_FREQ? n
                      DEFAULT_DEADLINE y
                      DEFAULT_IOSCHED? deadline
                      HPET_TIMER y
                      IOSCHED_DEADLINE y
                      RT_GROUP_SCHED? n
                      TREE_RCU_TRACE? n
                    '' + (
                      if truePreemptRT then ''
                        PREEMPT_RT_FULL? n
                        PREEMPT_VOLUNTARY y
                        PREEMPT y
                      '' else ''
                        PREEMPT_RT_FULL? y
                        PREEMPT_VOLUNTARY n
                        PREEMPT y
                      ''
                    );
                    enableParallelBuilding = true;

                    argsOverride = if truePreemptRT then {
                      src = super.fetchurl {
                        url = "mirror://kernel/linux/kernel/v4.x/linux-${kversion}.tar.xz";
                        sha256 = "1nlwgs15mc3hlfhqw95pz7wisg8yshzrxzzq2a0y30mjm5vbvj33";
                      };
                      version = fullVersion;
                      modDirVersion = fullVersion;
                    } else {};
                    kernelPatches = let
                      rtPatch = let
                        branch = "4.19";
                        sha256 = "fd91ed56a99009a45541a81e8d2d93780ac84b3ffa80a2d1615006d5e33be184";
                      in
                        {
                          name = "rt-${kversion}-${pversion}";
                          patch = super.fetchurl {
                            inherit sha256;
                            url = "https://www.kernel.org/pub/linux/kernel/projects/rt/${branch}/patch-${kversion}-${pversion}.patch.xz";
                          };
                        };
                    in
                      ksuper.kernelPatches ++ (if truePreemptRT then [ rtPatch ] else []);
                  };
                in
                  rtKernel
            );
          }
        )
      ) else [];

    config = {
      packageOverrides = pkgs: rec {
        ffado = pkgs.libsForQt5.callPackage ./ffado {
          inherit (pkgs.linuxPackages) kernel;
        };
        libffado = ffado;

        # not overriding (lib)jack2 to avoid too many dependency rebuilds
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
              commentout = 0
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

  security = {
    wrappers = {
      load-firewire-modules = {
        source = "${load-firewire-modules}";
        owner = "root";
        group = "audio";
        permissions = "u+rx,g+rx";
        capabilities = "cap_sys_module+ep";
      };
      # allow the audio services to change cpufreq governor
      cpupower = {
        source = "${pkgs.linuxPackages.cpupower}/bin/cpupower";
        owner = "root";
        group = "audio";
      };
      # allow pulse audio to set real-time priority
      pulseaudio = {
        source = "${pkgs.pulseaudioFull}/bin/pulseaudio";
        capabilities = "cap_sys_nice+eip";
        setsuid = false;
      };
    };
  };

  powerManagement.cpuFreqGovernor = lib.mkForce "powersave";
}

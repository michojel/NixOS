# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

let
  hostname = "nixosmounter";
  fqdn = hostname + ".vm";
  ipv4addr = "192.168.56.10";
in {
  imports = [
      ./hardware-configuration.nix
      ./bind-mounts.nix
      ./minap50/shell.nix
      ./minap50/docker.nix
      ./samba.nix
      #./container-minap50.nix
    ];

  nix = {
    gc = {
      automatic = true;
      dates = "19:15";
    };
    nixPath = [
      "nixpkgs=/etc/nixos/nixpkgs"
      "nixos-config=/etc/nixos/configuration.nix"
      "/etc"
    ];
  };

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.timeout = 1;
  boot.initrd.checkJournalingFS = false;
  boot.supportedFilesystems = ["zfs"];
  boot.extraModprobeConfig = ''
    options snd_intel8x0 ac97_clock=48000
  '';

  # move if lvm is used
  systemd.services = {
    systemd-udev-settle.serviceConfig.ExecStart = "${pkgs.coreutils}/bin/true";
    mpd = {
			after = lib.mkAfter  ["jackd.service"];
			requires = lib.mkAfter ["jackd.service"];
			serviceConfig = {
				ExecStartPre =
					lib.mkForce ("${pkgs.bash}/bin/bash" 
					+ " -c 'if [[ ! -e \"${config.services.mpd.dataDir}\" ]]; then"
					+ " mkdir -p \"${config.services.mpd.dataDir}\""
					+ " && chown -R ${config.services.mpd.user}:${config.services.mpd.group}"
					+ " \"${config.services.mpd.dataDir}\"; fi'");
				LimitMEMLOCK = "infinity";
			};
    };

    jackd = {
			description = "Jack slave";
			wantedBy = ["multi-user.target"];
			after = ["sound.target"];
			serviceConfig = {
				#ExecStart = "${pkgs.jack2Full}/bin/jackd -R -d netone";
				ExecStart = "${pkgs.jack2Full}/bin/jackd -R -d net";
				User = "mpd";
				LimitMEMLOCK = "infinity"; 
		  };
		};
  };

  networking = {
    hostName = fqdn;
    hostId = "1c64fb8b";
    hosts = {
      "${ipv4addr}" = [ hostname fqdn ];
      "192.168.56.51" = [ "ocentop" "ocentop.vm" "ocentop.minap50" ];
    };
    firewall = {
      enable          = true;
      allowPing       = true;
      allowedTCPPorts = [
				22 139 445    # samba
				config.services.mpd.network.port
        19000         # jack audio
        8123          # tor http proxy
			];
    };
    interfaces  = {
      "enp0s3"  = {
        useDHCP = true;
      };
      "enp0s8"         = {
        useDHCP        = false;
        ipv4.addresses = [ { address = ipv4addr ; prefixLength = 24; } ];
      };
    };
    networkmanager = {
      enable    = true;
      logLevel  = "INFO";
      unmanaged = ["enp0s8"];
    };
  };

  # Set your time zone.
  time.timeZone = "Europe/Prague";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    bindfs
    cifs-utils
    cryptsetup
    drive
    duplicity
    fdupes
    nodePackages.eslint
    nodePackages.eslint-config-google
    gist
    git
    gnupg1compat
    gitAndTools.git-annex
    gitAndTools.hub
    iftop
    iotop
    #nodePackages.jslint
    libxml2 		# xmllint
    linuxPackages.virtualboxGuestAdditions
    ncdu
    nixUnstable
    #nodePackages._at_google_slash_clasp
    #nodePackages._at_google_slash_clasp
    nodejs
    nodePackages."@google/clasp"
    #nodePackages.standard
    #nodePackages.xo
    parallel
    pinentry_ncurses
    pwgen
    samba
    sshfs
    tmuxinator
    unzip
    vimPlugins.fzfWrapper
    vimPlugins.fzf-vim
    vorbisTools
    yq

    # audio
    alsaUtils
    jack2Full
    jackmeter
    mpc_cli
    ncmpcpp

    # work related
    skopeo
    graphviz

    # devel
    pandoc
    python36Packages.autopep8
    python36Packages.flake8
    python36Packages.pylint
    python36Packages.yapf
    go
    glide
    gnumake

		# email
    afew
    gmailieer
    python27Packages.goobook
    #isync
    msmtp
		neomutt
		notmuch
  ];

  services.openssh = {
    enable = true;
    permitRootLogin = "yes";
  };

  services.mpd = {
		enable                = true;
		network.listenAddress = "${ipv4addr}";
		startWhenNeeded       = false;
 		extraConfig = ''
      max_output_buffer_size		"128000"
      audio_buffer_size		      "16384"
#      audio_output {
#          type			      "alsa"
#          name			      "My ALSA Device"
#          mixer_type      "software"
#          #mixer_device    "default"
#          #mixer_control   "PCM"
#          #format          "44100:16:2"
#          format          "48000:16:2"
#          #auto_resample	"no"
#      }
      audio_output {
        type        "jack"
        name        "My JACK Device"
      }
      zeroconf_enabled    "no"
    '';
    #network.host
  };

  services.tor = {
    enable = true;
    torsocks.enable = true;
    torsocks.allowInbound = true;
    #torsocks.server = "192.168.56.10:9050";
  };

  services.polipo = {
    enable = true;
    allowedClients = ["127.0.0.1" "::1" "192.168.56.0/24"];
    # map to top SOCKS proxy
    socksParentProxy = "localhost:9050";
    proxyAddress = "0.0.0.0";
  };

  nixpkgs.config.permittedInsecurePackages = [
    "polipo-1.1.1"
  ];


  hardware.pulseaudio.enable = false;
  sound = { 
    enable = true;
#    extraConfig = ''
#      pcm.card0 {
#        type hw
#        card 0
#      }
#
#      pcm.!default {
#        type plug
#        slave.pcm "dmixer"
#      }
#
#      pcm.dmixer {
#        type dmix
#        ipc_key 2048
#        slave {
#          pcm "hw:0,0"
#          period_time 0
#          period_size 2048
#          buffer_size 65536
#          buffer_time 0
#          periods 128
#          rate 48000
#          channels 2
#        }
#        bindings {
#          0 0
#          1 1
#        }
#      }
#    '';
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

  users.extraUsers.miminar = {
    isNormalUser = true;
    uid          = 1000;
    extraGroups  = [
      "wheel" "fuse" "docker" "audio" "networkmanager"
      "mpd"
      "utmp" 	# to open tmux
    ];
  };

	# needed for jackd
  security.rtkit.enable = true;
  security.pam.loginLimits = [
		{ domain = "@audio";
			item   = "rtprio";
			type   = "-";
			value  = "99";
 		}
		{ domain = "mpd";
			item   = "rtprio";
			type   = "-";
			value  = "99";
 		}
];
}

# vim: set ts=2 sw=2 :

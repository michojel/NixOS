{ config, pkgs, ... }:

{
  containers.minap50 = {
    autoStart = true;

    config =
      { config, pkgs, ... }:

      {
        imports = [ ./minap50/shell.nix ];

        users.extraUsers.miminar = {
          isNormalUser = true;
          uid = 1000;
          extraGroups = [ "wheel" "fuse" "docker" "audio" ];
        };
	users.extraGroups.docker.gid = config.ids.gids.docker;

        services.openssh = {
          enable = true;
          ports = [ 2222 ];
          permitRootLogin = "no";
        };

        environment.systemPackages = with pkgs; [
          docker nixUnstable
        ];

	#programs.gnupg.agent = { enable = true; enableSSHSupport = true; };
      };

    bindMounts = {
      "/home" = {
	 hostPath = "/mnt/minap50home";
         isReadOnly = false;
      };
      # this does not work
      "/etc/shadow" = {
	 hostPath = "/mnt/minap50root/etc/shadow";
      };
      "/run/docker" = {
	 hostPath = "/run/docker";
         isReadOnly = true;
      };
      "/run/docker.pid" = {
	 hostPath = "/run/docker.pid";
         isReadOnly = true;
      };
      "/run/docker.sock" = {
	 hostPath = "/run/docker.sock";
         isReadOnly = false;
      };
    };
  };

  systemd.services."container@minap50" = {
    requires = [ "docker.service" ];
    after = [ "docker.service" ];
  };
}

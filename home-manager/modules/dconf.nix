{ config, pkgs, lib, ... }:

let
  # TODO: share this somehome between modules
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
in
{
  dconf.settings = lib.mkIf (!systemConfig.profile.server.enable) {
    "org/gnome/desktop/interface" = {
      clock-show-seconds = true;
      clock-show-weekday = true;
      cursor-theme = "whiteglass";
      enable-animations = true;
      enable-hot-corners = false;
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-im-module = "gtk-im-context-simple";
      gtk-theme = "Arc-Darker";
      icon-theme = "Arc";
      show-battery-percentage = true;
      toolkit-accessibility = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/wm/keybindings" = {
      switch-group = [ ];
      maximize-horizontally = [ "<Alt><Super>h" ];
      maximize-vertically = [ "<Alt><Super>v" ];
      move-to-workspace-1 = [ "<Shift><Super>exclam" ];
      move-to-workspace-2 = [ "<Shift><Super>at" ];
      move-to-workspace-3 = [ "<Shift><Super>numbersign" ];
      move-to-workspace-4 = [ "<Shift><Super>dollar" ];
      #move-to-workspace-down=@as [];
      move-to-workspace-left = [ "<Shift><Super>braceleft" ];
      move-to-workspace-right = [ "<Shift><Super>braceright" ];
      #move-to-workspace-up=@as [];
      raise = [ "<Primary><Super>Up" ];
      raise-or-lower = [ "<Primary><Super>l" ];
      show-desktop = [ "<Alt><Super>period" ];
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      #switch-to-workspace-down=@as [];
      switch-to-workspace-left = [ "<Super>bracketleft" ];
      switch-to-workspace-right = [ "<Super>bracketright" ];
      #switch-to-workspace-up=@as [];
      switch-windows = [ "<Shift><Super>s" ];
      switch-windows-backward = [ "<Super>s" ];
      toggle-fullscreen = [ "<Super>f" ];
      toggle-on-all-workspaces = [ "<Shift><Super>w" ];
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,maximize,close";
      # focus-mode = "mouse";
      resize-with-right-button = true;
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-last-coordinates = lib.hm.gvariant.mkTuple [ 46.189000719942406 9.0221999999999998 ];
      night-light-temperature = 2226;
    };

    "org/gnome/settings-daemon/plugins/media-keys" = {
      area-screenshot = [ "<Shift>Print" ];
      area-screenshot-clip = [ "<Primary><Shift>Print" ];
      screensaver = [ "<Super><Shift>l" ];
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom17/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18/"
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom19/"
      ];
      decrease-text-size = [ "<Primary><Shift><Alt><Super>underscore" ];
      increase-text-size = [ "<Primary><Shift><Alt><Super>plus" ];
      mic-mute = [ "<Alt>AudioMute" ];
      next = [ "AudioNext" ];
      on-screen-keyboard = [ "<Primary><Shift><Alt><Super>k" ];
      play = [ "AudioPlay" ];
      previous = [ "AudioPrev" ];
      screenshot = [ "Print" ];
      screenshot-clip = [ "<Primary>Print" ];
      stop = [ "<Shift>AudioPause" ];
      toggle-contrast = [ "<Primary><Shift><Alt><Super>h" ];
      volume-down = [ "AudioLowerVolume" ];
      volume-mute = [ "AudioMute" ];
      volume-up = [ "AudioRaiseVolume" ];
      window-screenshot = [ "<Alt>Print" ];
      window-screenshot-clip = [ "<Primary><Alt>Print" ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "<Super>semicolon";
      command = "alacritty";
      name = "Launch Terminal";
    };

    "org/gnome/desktop/default-applications/terminal" = {
      exec = "alacritty";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "<Super><Shift>a";
      command = "goldendict";
      name = "Launch GoldenDict";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
      binding = "<Super>6";
      command = "wmctrl -s 6";
      name = "Switch to workspace 6";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom11" = {
      binding = "<Shift><Super>asciicircum";
      command = "wmctrl -r :ACTIVE: -t 6";
      name = "Move window to workspace 6";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom12" = {
      binding = "<Super>7";
      command = "wmctrl -s 7";
      name = "Switch to workspace 7";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom13" = {
      binding = "<Shift><Super>ampersand";
      command = "wmctrl -r :ACTIVE: -t 7";
      name = "Move window to workspace 7";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom14" = {
      binding = "<Super>8";
      command = "wmctrl -s 8";
      name = "Switch to workspace 8";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom15" = {
      binding = "<Shift><Super>asterisk";
      command = "wmctrl -r :ACTIVE: -t 8";
      name = "Move window to workspace 8";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom16" = {
      binding = "<Super>9";
      command = "wmctrl -s 9";
      name = "Switch to workspace 9";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom17" = {
      binding = "<Shift><Super>parenleft";
      command = "wmctrl -r :ACTIVE: -t 9";
      name = "Move window to workspace 9";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom18" = {
      binding = "<Super>0";
      command = "wmctrl -s 10";
      name = "Switch to workspace 10";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom19" = {
      binding = "<Shift><Super>parenright";
      command = "wmctrl -r :ACTIVE: -t 10";
      name = "Move window to workspace 10";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Super>x";
      command = "xkill";
      name = "Choose window to kill";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
      binding = "<Alt><Super>End";
      command = "sudo systemctl suspend-then-hibernate";
      name = "Suspend";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
      binding = "<Shift><Super>t";
      command = "wmctrl -r :ACTIVE: -b toggle,above";
      name = "Toggle window on top";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
      binding = "<Primary><Shift><Alt>p";
      command = "pavucontrol";
      name = "Launch PulseAudio Volume Control";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
      binding = "<Primary><Shift><Alt><Super>n";
      command = ''dbus-send --session --type=method_call --dest=org.gnome.Shell /org/gnome/Shell org.gnome.Shell.Eval string:"Main.panel.statusArea.dateMenu._messageList._sectionList.get_children().forEach(s => s.clear());"'';
      name = "Clear Gnome Notifications";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
      binding = "<Super>5";
      command = "wmctrl -s 5";
      name = "Switch to workspace 5";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
      binding = "<Shift><Super>percent";
      command = "wmcrl -r :ACTIVE: -t  5";
      name = "Move window to workspace 5";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      power-button-action = "interactive";
      sleep-inactive-ac-type = "nothing";
      sleep-inactive-battery-timeout = 900;
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/terminal/legacy/profiles:" = {
      default = "b1dcc9dd-5262-4d8d-a863-c897e6d979b9";
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      background-color = "rgb(23,20,33)";
      font = "MesloLGM Nerd Font 11";
      foreground-color = "rgb(208,207,204)";
      palette = [ "rgb(2320,33)" "rgb(192,28,40)" "rgb(38,162,105)" "rgb(162,115,76)" "rgb(18,72,139)" "rgb(163,71,186)" "rgb(42,161,179)" "rgb(208,207,204)" "rgb(94,92,100)" "rgb(246,97,81)" "rgb(51,209,122)" "rgb(233,173,12)" "rgb(42,123,222)" "rgb(192,97,203)" "rgb(51,199,222)" "rgb(255,255,255)" ];
      use-system-font = false;
      use-theme-colors = false;
      visible-name = "Dark";
    };

    "org/gnome/desktop/input-sources" = {
      per-window = false;
      show-all-sources = true;
      # TODO remove redundancy with xserver conf
      sources = [ (lib.hm.gvariant.mkTuple [ "xkb" "us+cz_sk_de" ]) (lib.hm.gvariant.mkTuple [ "xkb" "ru" ]) ];
      xkb-options = [ "terminate:ctrl_alt_bksp" "grp_led:scroll" "lv3:ralt_switch" "nbsp:level3" "compose:menu" ];
    };

    "org/gnome/shell/extensions/paperwm" = {
      default-focus-mode = 0; # 0 ~ default; 1 ~ center;
      winprops = [
        ''{ "wm_class": "anki", "title": "Profiles", "scratch_layer": true }''
        ''{ "wm_class": "GoldenDict", "scratch_layer": true }''
      ];
    };

    "org/gnome/shell/extensions/paperwm/keybindings" = {
      move-down-workspace = [ "<Control><Super>Page_Down" "<Shift><Super>braceright" ];
      move-up-workspace = [ "<Control><Super>Page_Up" "<Shift><Super>braceleft" ];
      switch-down-workspace = [ "<Super>Page_Down" "<Super>bracketright" ];
      switch-up-workspace = [ "<Super>Page_Up" "<Super>bracketleft" ];
    };

    "org/gnome/desktop/session" = {
      # blank screen after X seconds of inactivity
      idle-delay = lib.hm.gvariant.mkUint32 900;
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
      workspaces-only-on-primary = false;
      attach-modal-dialogs = false;
    };

    # for paperwm
    "org/gnome/shell" = {
      workspaces-only-on-primary = false;
      edge-tiling = false;
      attach-modal-dialogs = false;
    };

    "org/gnome/shell/app-switcher" = {
      current-workspace-only = true;
    };

    # GPG keys password caching timeout
    "org/gnome/crypto/cache" = {
      gpg-cache-method = "timeout";
      gpg-cache-ttl = config.services.gpg-agent.defaultCacheTtl;

      ssh-cache-method = "timeout";
      ssh-cache-ttl = config.services.gpg-agent.defaultCacheTtlSsh;
    };

    "desktop/gnome/crypto/cache" = {
      gpg-cache-method = "timeout";
      gpg-cache-ttl = config.services.gpg-agent.defaultCacheTtl;

      ssh-cache-method = "timeout";
      ssh-cache-ttl = config.services.gpg-agent.defaultCacheTtlSsh;
    };
  };
}

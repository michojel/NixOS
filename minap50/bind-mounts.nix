{ config, ... }:

{
  fileSystems."/home/miminar/.mpd/Music" =
    { device = "/home/miminar/Audio";
      options = [ "bind" ]; 
    };
}

# vim: set ts=2 sw=2 :

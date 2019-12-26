{ config, pkgs, ... }:

rec {
  nixpkgs.config = {
    packageOverrides = pkgs: rec {
      mfcj5730dwlpr = pkgs.callPackage ./mfcj5730dwlpr {};
      mfcj5730dwcupswrapper = pkgs.callPackage ./mfcj5730dwcupswrapper {};
    };
    allowUnsupported = true;
  };

  environment.systemPackages = with pkgs; [
    mfcj5730dwcupswrapper
  ];
  services.printing.drivers = with pkgs; [
    gutenprint
    gutenprintBin
    hplip
    hplipWithPlugin
    brgenml1lpr
    brgenml1cupswrapper
    mfcj5730dwcupswrapper
    mfcj5730dwlpr
  ];
}

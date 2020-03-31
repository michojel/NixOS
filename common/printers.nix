{ config, pkgs, ... }:

rec {
  nixpkgs = {
    overlays = [
      (
        self: super: {
          mfcj5730dwlpr = super.callPackage ./mfcj5730dwlpr {};
          mfcj5730dwcupswrapper = super.callPackage ./mfcj5730dwcupswrapper {};
        }
      )
    ];
    config = {
      allowUnsupported = true;
    };
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

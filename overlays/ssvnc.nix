self: super: {
  ssvnc = super.callPackage /mnt/nixos/common/ssvnc.nix {
    fontDirectories = with super; [
      xorg.fontadobe75dpi
      xorg.fontbhlucidatypewriter75dpi
      xorg.fontcursormisc
      xorg.fontmiscmisc
    ];
  };
}

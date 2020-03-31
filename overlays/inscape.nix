self: super: {
  # new package to avoid massive rebuilds
  inkscape-gs = (
    super.inkscape.override {
      imagemagick = super.imagemagickBig;
    }
  ).overrideAttrs (
    attrs: {
      buildInputs = attrs.buildInputs ++ [ super.ghostscript ];
      runtimeDependencies = (super.lib.attrByPath [ "runtimeDependencies" ] [] attrs) ++ [ self.pstoedit-gs ];
      postInstall = attrs.postInstall + ''
        wrapProgram $out/bin/inkscape --prefix PATH : "${super.stdenv.lib.makeBinPath [ self.pstoedit-gs ]}"
      '';
    }
  );

  pstoedit-gs = (
    super.pstoedit.override {
      imagemagick = super.imagemagickBig;
    }
  ).overrideAttrs (
    attrs: {
      buildInputs = attrs.buildInputs ++ [ super.makeWrapper ];
      runtimeDependencies = (super.lib.attrByPath [ "runtimeDependencies" ] [] attrs) ++ [ super.ghostscript ];
      postInstall = (super.lib.attrByPath [ "postInstall" ] "" attrs) + ''
        wrapProgram $out/bin/pstoedit --prefix PATH : "${super.stdenv.lib.makeBinPath [ super.ghostscript ]}"
      '';
    }
  );
}

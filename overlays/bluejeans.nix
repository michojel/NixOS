self: super: {
  bluejeans-gui = super.bluejeans-gui.overrideDerivation (
    oldAttrs:
    let
      version = "2.20.0";
      revision = "118";
    in
    {
      version = version;
      name = "bluejeans-gui-${version}";
      src = super.fetchurl {
        url = "https://swdl.bluejeans.com/desktop-app/linux/${version}/BlueJeans_${version}.${revision}.rpm";
        sha256 = "0bi4wmqsdj74ifgwjq1jvzccm3x9ixqja7i091qpzgds132gaabq";
      };
    }
  );
}

self: super: {
  bluejeans-gui = super.bluejeans-gui.overrideDerivation (
    oldAttrs:
    let
      version = "2.21.3";
      revision = "2";
    in
    {
      version = version;
      name = "bluejeans-gui-${version}";
      src = super.fetchurl {
        url = "https://swdl.bluejeans.com/desktop-app/linux/${version}/BlueJeans_${version}.${revision}.rpm";
        sha256 = "006mlcrxmcgldds3vx03aghvpnh12i40jxxkdg5n4ria36xl9x3b";
      };
    }
  );
}

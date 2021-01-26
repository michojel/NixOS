self: super:
let
  version = "2.2.0";
in
{

  ankisyncd = super.ankisyncd.overrideAttrs
    (
      attrs: {
        version = version;

        src = super.fetchFromGitHub {
          owner = "ankicommunity";
          repo = "anki-sync-server";
          rev = "${version}";
          sha256 = "196xhd6vzp1ncr3ahz0bv0gp1ap2s37j8v48dwmvaywzayakqdab";
        };

        installPhase = ''
          runHook preInstall

          mkdir -p $out/${super.python3.sitePackages}

          cp -r ankisyncd utils ankisyncd.conf $out/${super.python3.sitePackages}
          mkdir $out/share
          cp ankisyncctl.py $out/share/

          runHook postInstall
        '';
      }
    );
}

self: super:
let
  version = "2.4.0";
  rev = "5beabf97642dcceaaaae46d4590a13a7bd980787";
in
{

  ankisyncd = super.ankisyncd.overrideAttrs
    (
      attrs: {
        version = version;
        name = "ankisyncd-${version}";

        src = super.fetchFromGitHub {
          owner = "ankicommunity";
          repo = "anki-sync-server";
          rev = "${rev}";
          sha256 = "sha256-WSPqXuDNOt/BB4jxdFRIUkscM+gfB0Wj1xpCgWJi5gY=";
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

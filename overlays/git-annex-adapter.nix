self: super:

let
  git-annex-adapter = super.python311Packages.git-annex-adapter.overrideAttrs (
    attrs: {
      doCheck = false;
      checkPhase = "";
      doInstallCheck = false;
    }
  );
in
{
  python311Packages = super.python311Packages // {
    git-annex-adapter = git-annex-adapter;
  };

  git-annex-adapter = git-annex-adapter;
}

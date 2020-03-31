self: super:
let
  version = "4.3.1.0";
in
{
  megasync = super.megasync.overrideAttrs (
    attrs: {
      version = version;

      src = super.fetchFromGitHub {
        owner = "meganz";
        repo = "MEGAsync";
        rev = "v${version}_Linux";
        sha256 = "0l4yfrxjb62vc9dnlzy8rjqi68ga1bys5x5rfzs40daw13yf1adv";
        fetchSubmodules = true;
      };
    }
  );
}

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
        sha256 = "0b68wpif8a0wf1vfn1nr19dmz8f31dprb27jpldxrxhyfslc43yj";
        fetchSubmodules = true;
      };
    }
  );
}

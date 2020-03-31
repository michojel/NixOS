self: super: {
  # https://github.com/NixOS/nixpkgs/pull/78043
  python37 = (
    super.python37 // {
      pkgs = (
        super.python37.pkgs // {
          pycurl = super.python37.pkgs.pycurl.overrideAttrs (
            attrs: {
              doCheck = false;
            }
          );
        }
      );
    }
  );
}

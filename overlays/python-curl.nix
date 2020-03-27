let
  # https://github.com/NixOS/nixpkgs/pull/78043
  python37pycurlOverlay = self: super: {
    python37.pkgs.pycurl = super.python37.pkgs.pycurl.override {
      doCheck = false;
    };
  };

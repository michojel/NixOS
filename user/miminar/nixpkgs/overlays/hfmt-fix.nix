self: super: let
  hlib = super.haskell.lib;
in {
  haskellPackages = super.haskellPackages.override (old: {
    overrides = super.lib.composeExtensions (old.overrides or (self: super: {}))
      (hself: hsuper: {

        hfmt = hlib.dontCheck (hlib.overrideCabal (hsuper.hfmt.override {
          stylish-haskell = hlib.doJailbreak (hself.stylish-haskell.override {
            haskell-src-exts = hself.haskell-src-exts_1_21_0;
          });
          hindent = hlib.appendPatch (hself.hindent.override {
            haskell-src-exts = hself.haskell-src-exts_1_21_0;
          }) (super.fetchpatch {
            # From https://github.com/chrisdone/hindent/pull/537
            # to fix with haskell-src-exts >=1.21
            url = "https://github.com/felixonmars/hindent/commit/ce033ca1087b6155315eefe5a3e8ba6f29d1b76c.patch";
            sha256 = "0rpdhf2qmi6i37s88qb4z2lj2zidq2k5q38xgagffx2y6kcyphkz";
          });
        }) (drv: {
          broken = false;
        }));

      });
  });
}

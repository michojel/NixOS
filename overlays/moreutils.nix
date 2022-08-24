self: super: {
  moreutils = super.moreutils.overrideAttrs (attrs: {
    # lower the package priority to make "GNU parallel" and "ts" take precedence
    priority = 15;
  });
}

self: super: {
  gitlab-shell = super.gitlab-shell.overrideAttrs (attrs: {
    # Lower priority than coreutils.
    priority = super.coreutils.meta.priority + 10;
  });
}

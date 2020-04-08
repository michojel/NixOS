self: super: {
  # make sure this takes precedence over moreutils.parallel
  parallel = super.lib.hiPrio super.parallel;
}

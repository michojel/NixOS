self: super: {
  python311Packages = super.python311Packages // {
    clustershell = super.python311Packages.clustershell.overridePythonAttrs (old: {
      doCheck = false;
    });
  };
}

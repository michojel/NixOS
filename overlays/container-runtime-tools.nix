self: super:

{
  oci-runtime-tools = super.buildGoPackage rec {
    pname = "oci-runtime-tools";
    version = "0.9.0";

    src = super.fetchFromGitHub {
      owner = "opencontainers";
      repo = "runtime-tools";
      rev = "v${version}";
      sha256 = "sha256-Sgd44zwxc9q0ent4avp5Mm6EDpfHDfT/nzThHJYckd4=";
    };

    goPackagePath = "github.com/opencontainers/runtime-tools";

    vendorHash = null;

    subPackages = [
      "cmd/oci-runtime-tool"
    ];

    ldflags = [
      "-s"
      "-w"
      "-X main.commit=${version}"
      "-X main.version=${version}"
    ];

    #ldflags = [
    #"-s"
    #"-w"
    #"-X sigs.k8s.io/controller-tools/pkg/version.version=v${version}"
    #];

    doCheck = false;

    #subPackages = [
    #"cmd/controller-gen"
    #"cmd/type-scaffold"
    #"cmd/helpgen"
    #];

    meta = with super.lib; {
      description = "OCI Runtime Tools";
      homepage = "https://github.com/opencontainers/runtime-tools";
      license = licenses.asl20;
      maintainers = with maintainers; [ michojel ];
    };
  };
}

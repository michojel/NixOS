self: super:

{
  controller-tools = super.buildGoModule rec {
    pname = "controller-tools";
    version = "0.6.2";

    src = super.fetchFromGitHub {
      owner = "kubernetes-sigs";
      repo = pname;
      rev = "v${version}";
      sha256 = "0hbai8pi59yhgsmmmxk3nghhy9hj3ma98jq2d1k46n46gr64a0q5";
    };

    vendorSha256 = "061qvq8z98d39vyk1gr46fw5ynxra154s90n3pb7k1q7q45rg76j";

    doCheck = false;

    subPackages = [
      "cmd/controller-gen"
      "cmd/type-scaffold"
      "cmd/helpgen"
    ];

    #nativeBuildInputs = [ super.makeWrapper ];
    #buildInputs = [ super.go ];

    # controller-runtime uses the go compiler at runtime
    #allowGoReference = true;
    #postFixup = ''
    #wrapProgram $out/bin/controller-runtime --prefix PATH : ${super.lib.makeBinPath [ super.go ]}
    #'';

    meta = with super.lib; {
      description = "Tools to use with the Kubernetes controller-runtime libraries";
      homepage = "https://github.com/kubernetes-sigs/controller-tools";
      license = licenses.asl20;
      maintainers = with maintainers; [ michojel ];
      platforms = platforms.linux ++ platforms.darwin;
    };
  };
}

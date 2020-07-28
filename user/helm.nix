{ pkgs ? import <nixpkgs> {}
, version ? "3.0.2"
, ... }:

let
  ver2sha = {
    "3.0.2" = "16q14x3y0dhgnspiyllds54r4sfw32zw0vcnfzk7sgvzj8ymg0ab";
  };

  mkhelmdev = ver: sha256: deps: with pkgs; buildGoModule rec {
    pname = "helm";
    version = "${ver}";

    src = fetchFromGitHub {
      owner = "helm";
      repo = "helm";
      rev = "v${ver}";
      sha256 = "1271lm81axw17fqkim39pya1lwfhc61z9h1yn2qalr7cdnijvkbf";
    };
    vendorSha256 = "0qgjl9ca4hh780qw6yspqa3wvmi3v99ff05a8ygmjcrbn7gwrmqj";

    subPackages = [ "cmd/helm" ];
    buildFlagsArray = [ "-ldflags=-w -s -X helm.sh/helm/v3/internal/version.version=v${version}" ];

    nativeBuildInputs = [ installShellFiles ];
    postInstall = ''
      $out/bin/helm completion bash > helm.bash
      $out/bin/helm completion zsh > helm.zsh
      installShellCompletion helm.{bash,zsh}
    '';

    meta = with stdenv.lib; {
      homepage = https://github.com/kubernetes/helm;
      description = "A package manager for kubernetes";
      license = licenses.asl20;
    };
  };

in rec {

  packageOverrides = pkgs: with pkgs; {
    helm-dev = mkhelmdev "${version}" ver2sha."${version}".install [];
  };
}

{ lib, buildNpmPackage, fetchurl }:

buildNpmPackage rec {
  pname = "github-copilot-cli";
  version = "0.1.33";

  src = fetchurl {
    url = "https://registry.npmjs.org/@githubnext/github-copilot-cli/-/github-copilot-cli-${version}.tgz";
    hash = "sha256-Au/SH5+um2Ngufq/+NNSlSqNuAIwC9LtVi4c95yzxwg=";
  };

  npmDepsHash = "sha256-YduUB7nIkFxWgH460RMd3hEVzYcZigHVYsXExaUz3yg=";

  postPatch = "cp ${./package-lock.json} package-lock.json";

  # The prepack script runs the build script, which we'd rather do in the build phase.
  npmPackFlags = [ "--ignore-scripts" ];

  makeCacheWritable = true;
  npmFlags = [ "--legacy-peer-deps" ];

  # NODE_OPTIONS = "--openssl-legacy-provider";

  meta = with lib; {
    description = "A CLI experience for letting GitHub Copilot help you on the command line";
    homepage = "https://githubnext.com/projects/copilot-cli";
    maintainers = with maintainers; [ cfeeley ];
  };
}

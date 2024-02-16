{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
  };

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = { config, self', pkgs, lib, system, ... }:
        let

          nodejs = pkgs.nodejs_20; # or pkgs.nodejs_18
          yarn = pkgs.yarn.override { inherit nodejs; };
          git = pkgs.git;

          startScript = pkgs.writeScriptBin "start" ''
            #!/bin/sh
            if [ -f "package.json" ]; then
              # Check if package.json contains the string "name": "omnitool"
              if grep -q '"name": "omnitool"' package.json; then
                ${yarn}/bin/yarn
                ${yarn}/bin/yarn start -u -rb "$@"
              else
                echo "Please run this script in the root of the omnitool repository."
                exit 1
              fi
            else
              echo "Please run this script in the root of the omnitool repository."
              exit 1
            fi
          '';

        in
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
          };

          devShells.default = pkgs.mkShell {
            name = "omnitool";

            # These packages are added to PATH,
            # search for packages on https://search.nixos.org/packages?channel=unstable
            nativeBuildInputs = [
              # Needed
              nodejs
              yarn
              git

              # Optional
              pkgs.curl # https://omnitool-ai.gitbook.io/omnitool/advanced/run-recipe-via-rest-api#id-2.-executing-a-recipe
              pkgs.jq
              startScript
            ];

            shellHook = ''
              source ${git}/share/git/contrib/completion/git-prompt.sh
              export PS1='\W\[\033[0;36m\]$(__git_ps1 " %s")\[\033[0m\] % '
            '';
          };
        };
    };
}

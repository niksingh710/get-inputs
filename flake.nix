{
  description = "Description for the project";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    emanote.url = "github:srid/emanote";
    flake = { };
  };
  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      perSystem = { config, self', inputs', pkgs, system, self, ... }:
        let

          dfs = input:
            {
              path = input;
              "inputs" =
                if builtins.hasAttr "inputs" input then
                  builtins.mapAttrs (name: value: dfs value) input.inputs
                else null;
            };
        in
        {
          packages.default = pkgs.writeText "
                output.json " ''
            ${builtins.toJSON (dfs inputs.flake)}
          '';
        };
    };
}

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
          dfs = input: seen:
            if builtins.hasAttr "inputs" input then
              let
                inputs = builtins.mapAttrs
                  (name: value:
                    if builtins.hasAttr name seen then
                      seen.${name}
                    else
                      dfs value (seen // { "${name}" = value; })
                  )
                  input.inputs;
              in
              {
                path = input;
                inputs = inputs;
              }
            else
              {
                path = input;
              };
        in
        {
          packages.default = pkgs.writeText "output.json"
            ''
              ${builtins.toJSON (dfs inputs.flake {})}
            '';
        };
    };
}

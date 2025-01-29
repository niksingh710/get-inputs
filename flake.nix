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
          # better dfs approach
          bdfs = input: seen:
            let
              isFlake = builtins.hasAttr "inputs" input;
              inputs =
                if isFlake then
                  builtins.mapAttrs
                    (name: value:
                      if builtins.hasAttr name seen then
                        seen.${name}
                      else
                        bdfs value (seen // { "${name}" = value; })
                    )
                    input.inputs
                else { };
            in
            {
              path = input;
              inputs = inputs;
              flake = isFlake;
            };

          # Older dfs approach
          # dfs = input: seen:
          #   if builtins.hasAttr "inputs" input then
          #     let
          #       inputs = builtins.mapAttrs
          #         (name: value:
          #           if builtins.hasAttr name seen then
          #             seen.${name}
          #           else
          #             dfs value (seen // {
          #               "${name}" = value;
          #             })
          #         )
          #         input.inputs;
          #     in
          #     {
          #       path = input;
          #       inputs = inputs;
          #       flake = true;
          #     }
          #   else
          #     {
          #       path = input;
          #       flake = false;
          #     };
        in
        {
          packages.default = pkgs.writeText "output.json"
            ''
              ${builtins.toJSON (bdfs inputs.flake {})}
            '';
        };
    };
}

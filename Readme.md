# To fetch all flake inputs recursively

```nix
nix build --override-input flake github:srid/emanote github:niksingh710/get-inputs -o inputs && cat inputs | jq
```

```sh
# => print all inputs of the nix repository flake, transitively
cat $(nix build --print-out-paths github:niksingh710/get-inputs --override-input flake github:nixos/nix)

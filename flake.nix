{
  description = "Rayed BQN is a library made to write cross-platform applications using the [BQN programming language";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    BQN386   = { url = "github:dzaima/BQN386"      ; flake = false; };
    bqn-libs = { url = "github:mlochbaum/bqn-libs" ; flake = false; };
    BQNoise  = { url = "github:mlochbaum/BQNoise"  ; flake = false; };

    raylib-bqn-f = {
      url = "github:Brian-ED/raylib-bqn";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {nixpkgs, BQN386, bqn-libs, BQNoise, raylib-bqn-f, ...}:
  let
    supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" ];
    forAllSystems = f: builtins.listToAttrs (map (system: {
      name = system;
      value = f system;
    }) supportedSystems);
  in {
    packages = forAllSystems (system:
    let
      pkgs = nixpkgs.legacyPackages.${system};
      raylib-bqn = raylib-bqn-f.packages.${pkgs.stdenv.hostPlatform.system}.default;
      rayed-bqn = pkgs.stdenv.mkDerivation {
        pname = "rayed-bqn";
        version = "rolling";
        meta = {
          description = "Rayed BQN is a library made to write cross-platform applications using the BQN programming language. It inter-ops with raylib via FFI, but changes a lot of raylib's functions to be more in-lined with BQN's syntax.";
          license = pkgs.lib.licenses.mit;
        };
        src = ./.;
        installPhase = ''
          mkdir -p "$out/imports" "$out/lib"
          cp rayed.bqn "$out/"
          cp -r src "$out/"
          cp -r examples "$out/"
          ln -s "${BQN386    }" "$out/imports/BQN386"
          ln -s "${bqn-libs  }" "$out/imports/bqn-libs"
          ln -s "${BQNoise   }" "$out/imports/BQNoise"
          ln -s "${raylib-bqn}" "$out/imports/raylib-bqn"
          ln -s "${pkgs.raylib}/lib/libraylib.so.6.0.0" "$out/lib/libraylib.so"
        '';
      };
    in {
      inherit rayed-bqn;
      default = rayed-bqn;
    });
  };
}

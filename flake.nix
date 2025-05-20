{
  description = "Rayed-bqn derivation and dev shell with BQN";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    BQN386     = { url = "github:dzaima/BQN386"      ; flake = false; };
    bqn-libs   = { url = "github:mlochbaum/bqn-libs" ; flake = false; };
    BQNoise    = { url = "github:mlochbaum/BQNoise"  ; flake = false; };
    raylib-bqn = { url = "github:Brian-ED/raylib-bqn"; flake = false; };
  };

  outputs = {nixpkgs, BQN386, bqn-libs, BQNoise, raylib-bqn, ...}:
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
      rayed-bqn = pkgs.stdenv.mkDerivation (finalAttrs: {
        pname = "rayed-bqn";
        version = "rolling";
        meta = {
          description = "Rayed BQN is a library made to write cross-platform applications using the BQN programming language. It inter-ops with raylib via FFI, but changes a lot of raylib's functions to be more in-lined with BQN's syntax.";
          homepage = "https://brian-ed.github.io/rayed-bqn-docs/";
          license = pkgs.lib.licenses.mit;
          maintainers = [ ];
          platforms = pkgs.lib.platforms.all;
        };
        src = ./.;
        installPhase = ''
          mkdir $out/
          mkdir $out/imports
          touch $out/install-raylib.bqn
          cp rayed.bqn $out/
          cp -r src $out/
          mkdir $out/lib
          ln -s ${BQN386    } $out/imports/BQN386
          ln -s ${bqn-libs  } $out/imports/bqn-libs
          ln -s ${BQNoise   } $out/imports/BQNoise
          ln -s ${raylib-bqn} $out/imports/raylib-bqn
          ln -s ${pkgs.raylib.outPath}/lib/libraylib.so.5.5.0 $out/lib/libraylib.so
        '';
      });
    in {
      inherit rayed-bqn;
      default = rayed-bqn;
      devShells.${system}.default = pkgs.mkShell {
        name = "rayed-bqn-shell";
        buildInputs = [
          pkgs.cbqn
        ];
      };
    });
  };
}
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    devshell.url = "github:numtide/devshell";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    nixconfig = {
      url = "github:3waffel/nixconfig/raspi";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    flake-utils,
    devshell,
    nixos-generators,
    nixos-hardware,
    nixconfig,
    ...
  } @ flakes:
    flake-utils.lib.eachSystem ["aarch64-linux"] (
      system: let
        stable = import nixpkgs {
          inherit system;
        };
        unstable = import nixpkgs-unstable {
          inherit system;
        };
      in rec {
        packages.rpi4 = nixos-generators.nixosGenerate {
          pkgs = stable;
          modules = [
            nixos-hardware.nixosModules.raspberry-pi-4
            ./images/raspi.nix
          ];
          format = "sd-aarch64";
        };
        packages.rpi4-installer = nixos-generators.nixosGenerate {
          pkgs = stable;
          format = "sd-aarch64-installer";
          modules = [nixos-hardware.nixosModules.raspberry-pi-4];
        };
        packages.default = packages.rpi4;
      }
    );
}

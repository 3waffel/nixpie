{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-22.05";
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
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware";
    };
    nixconfig = {
      url = "github:3waffel/nixconfig";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    devshell,
    nixos-generators,
    nixos-hardware,
    nixconfig,
    ...
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [
            devshell.overlay
          ];
        };
        pkgs-rpi = import nixpkgs {
          system = "aarch64-linux";
          overlays = [
            (final: super: {
              makeModulesClosure = x:
                super.makeModulesClosure (x // {allowMissing = true;});
            })
          ];
        };
      in rec {
        packages.rpi4 = nixos-generators.nixosGenerate {
          pkgs = pkgs-rpi;
          format = "sd-aarch64";
          modules = [nixos-hardware.nixosModules.raspberry-pi-4];
        };
        packages.rpi4-installer = nixos-generators.nixosGenerate {
          pkgs = pkgs-rpi;
          format = "sd-aarch64-installer";
          modules = [nixos-hardware.nixosModules.raspberry-pi-4];
        };
        packages.default = packages.rpi4;
        devShells.default = pkgs.devshell.mkShell {
          imports = [
            (pkgs.devshell.importTOML ./devshell.toml)
          ];
        };
      }
    );
}

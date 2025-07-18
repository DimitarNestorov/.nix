{
  description = "System configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    darwin.url = "github:lnl7/nix-darwin/nix-darwin-24.11";
    darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    personal-nur.url = "github:DimitarNestorov/Nix-user-repository-packages";
    personal-nur.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    {
      self,
      darwin,
      nixpkgs,
      nixpkgs-unstable,
      nix-index-database,
      home-manager,
      personal-nur,
      ...
    }@inputs:
    let
      darwinModules = [
        ./configuration.nix
        home-manager.darwinModules.home-manager
        nix-index-database.darwinModules.nix-index
        {
          nix.registry = {
            nixpkgs.flake = nixpkgs;
            nixpgks.flake = nixpkgs;
            nixpkgs-unstable.flake = nixpkgs-unstable;
            nixpgks-unstable.flake = nixpkgs-unstable;
          };
        }
      ];

      configuration =
        {
          system,
          type ? "personal",
          dimitar-uuid,
        }:
        let
          pkgs-unstable = import inputs.nixpkgs-unstable {
            inherit system;
            config.allowUnfreePredicate =
              pkg:
              builtins.elem (nixpkgs.lib.getName pkg) [
                "aldente"
                "mactracker"
                "rapidapi"
                "Xcode.app"
              ];
          };
        in
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = {
            inherit type dimitar-uuid;
          };
          modules = darwinModules ++ [
            {
              nixpkgs.overlays = [
                (self: super: {
                  xcode = pkgs-unstable.darwin.xcode_16_2;
                  devenv = pkgs-unstable.devenv;
                  vscodium = pkgs-unstable.vscodium;
                  mactracker = pkgs-unstable.mactracker;
                  aldente = pkgs-unstable.aldente;
                  colorls = pkgs-unstable.colorls;
                  rapidapi = pkgs-unstable.rapidapi;
                })
                personal-nur.overlay
              ];
            }
          ];
        };
    in
    {
      darwinConfigurations = {
        adonis = configuration {
          system = "aarch64-darwin";
          dimitar-uuid = "08B5F559-BC13-4D11-AFBE-0CC7F1E58EDF"; # Find in System Preferences -> Users & Groups -> Advanced Options
        };
        jason = configuration { system = "aarch64-darwin"; };
        helenus = configuration { system = "x86_64-darwin"; };
        work = configuration {
          system = "aarch64-darwin";
          type = "work";
          dimitar-uuid = "3078B925-5564-4B6D-A8DF-747490244783";
        };
      };
    };
}

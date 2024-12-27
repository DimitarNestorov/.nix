{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-rapidapi.url = "github:nixos/nixpkgs/6e71a1a5a65d6c4faf9ebfd71b7184580abd2e5c";
		nixpkgs-colorls.url = "github:nixos/nixpkgs/48d275c3de4e2aece7d26179fd6e33a47daff39d";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager/release-24.11";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		self,
		darwin,
		nixpkgs,
		nixpkgs-unstable,
		nix-index-database,
		home-manager,
		...
	} @ inputs: let
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

		configuration = { system, type ? "personal" }: let
			pkgs-colorls = import inputs.nixpkgs-colorls { inherit system; };
			pkgs-unstable = import inputs.nixpkgs-unstable {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"aldente"
					"mactracker"
				];
			};
			pkgs-rapidapi = import inputs.nixpkgs-rapidapi {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"rapidapi"
				];
			};
		in darwin.lib.darwinSystem {
			inherit system;
			specialArgs = {
				inherit type;
			};
			modules = darwinModules ++ [
				{
					nixpkgs.overlays = [
						(self: super: {
							mactracker = pkgs-unstable.mactracker;
							aldente = pkgs-unstable.aldente;
							rapidapi = pkgs-rapidapi.rapidapi;
							colorls = pkgs-colorls.colorls;
						})
					];
				}
			];
		};
	in {
		darwinConfigurations = {
			adonis = configuration { system = "aarch64-darwin"; };
			jason = configuration { system = "aarch64-darwin"; };
			helenus = configuration { system = "x86_64-darwin"; };
			work = configuration { system = "aarch64-darwin"; type = "work"; };
		};
	};
}

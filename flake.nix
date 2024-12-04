{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/820af6cb19862e5929bc0c76b278edfc67582e3d";
		nixpkgs-iterm2.url = "github:nixos/nixpkgs/99d697b87b118231962a0da12754ffe36d5a8ead";
		nixpkgs-rapidapi.url = "github:nixos/nixpkgs/6e71a1a5a65d6c4faf9ebfd71b7184580abd2e5c";
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
					nixpkgs-unstable.flake = nixpkgs-unstable;
				};
			}
		];

		configuration = { system, type ? "personal" }: let
			pkgs-iterm2 = import inputs.nixpkgs-iterm2 { inherit system; };
			pkgs-aldente = import inputs.nixpkgs-aldente {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"aldente"
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
							aldente = pkgs-aldente.aldente;
							iterm2 = pkgs-iterm2.iterm2;
							rapidapi = pkgs-rapidapi.rapidapi;
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

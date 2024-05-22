{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		# nixpkgsUnstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		# home-manager.url = "github:nix-community/home-manager";
		# home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, darwin, nixpkgs, nix-index-database, ... }@inputs: 
	let
		modules = [
			./configuration.nix
			nix-index-database.nixosModules.nix-index
			{ nix.nixPath = [ "nixpkgs=${nixpkgs.outPath}" ]; }
		];
		# homeManagerCommonConfig = with self.homeManagerModules; {
		# 	imports = [
		# 		./home
		# 	];
		# };
	in {
		darwinConfigurations."adonis" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = modules;
		};

		darwinConfigurations."jason" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = modules;
		};

		darwinConfigurations."helenus" = darwin.lib.darwinSystem {
			system = "x86_64-darwin";
			modules = modules;
		};
	};
}

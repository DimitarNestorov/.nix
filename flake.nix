{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		# nixpkgsUnstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database/838a910df0f7e542de2327036b2867fd68ded3a2";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager/release-24.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, darwin, nixpkgs, nix-index-database, home-manager, ... }@inputs: 
	let
		modules = [
			./configuration.nix

			home-manager.darwinModules.home-manager
			{
				home-manager.useGlobalPkgs = true;
				home-manager.useUserPackages = true;
				home-manager.users.dimitar = import ./home.nix;
			}

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

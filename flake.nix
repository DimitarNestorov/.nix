{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-23.11-darwin";
		# nixpkgsUnstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:Mic92/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		# home-manager.url = "github:nix-community/home-manager";
		# home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, darwin, nixpkgs, nix-index-database, ... }@inputs: 
	let
		configuration = { pkgs, ... }: {
			nix = {
				package = pkgs.nixFlakes;
				
				extraOptions = ''
experimental-features = nix-command flakes
'' + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
system = aarch64-darwin
'';
			};

			services.nix-daemon.enable = true;
		};

		# homeManagerCommonConfig = with self.homeManagerModules; {
		# 	imports = [
		# 		./home
		# 	];
		# };
	in {
		darwinConfigurations."adonis" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = [
				configuration
				./configuration.nix
				nix-index-database.nixosModules.nix-index
				{ programs.nix-index-database.comma.enable = true; }
			];
		};

		darwinConfigurations."jason" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = [ configuration ./configuration.nix ];
		};

		darwinConfigurations."helenus" = darwin.lib.darwinSystem {
			system = "x86_64-darwin";
			modules = [ configuration ./configuration.nix ];
		};
	};
}

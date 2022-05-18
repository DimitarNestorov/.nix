{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
		nixpkgsUnstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		google-fonts.url = "github:dimitarnestorov/nix-google-fonts-overlay/master";
		# home-manager.url = "github:nix-community/home-manager";
		# home-manager.inputs.nixpkgs.follows = "nixpkgs";
		comma.url = "github:dimitarnestorov/comma?rev=2ea4a7467512ec164d8ec953babd603f63a146bb";
		comma.inputs.nixpkgs.follows = "nixpkgsUnstable";
	};

	outputs = { self, darwin, nixpkgs, ... }@inputs: 
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

			nixpkgs = {
				overlays = with inputs; [
					(final: prev: {
						iterm2 = nixpkgsUnstable.legacyPackages.${prev.system}.iterm2;
						comma = comma.defaultPackage.${prev.system};
					})
					google-fonts.lib
				];
			};
		};

		# homeManagerCommonConfig = with self.homeManagerModules; {
		# 	imports = [
		# 		./home
		# 	];
		# };
	in {
		darwinConfigurations."Dimitars-MacBook-Pro" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = [ configuration ./configuration.nix ];
		};

		darwinConfigurations."Dimitars-Mac-mini" = darwin.lib.darwinSystem {
			system = "aarch64-darwin";
			modules = [ configuration ./configuration.nix ];
		};

		darwinConfigurations."Dimitars-Work-Hackintosh" = darwin.lib.darwinSystem {
			system = "x86_64-darwin";
			modules = [ configuration ./configuration.nix ];
		};
	};
}

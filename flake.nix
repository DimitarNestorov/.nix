{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.05";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/619551a371d2cc1cb7288e65a11c943c7e5a55fc";
		nixpkgs-bartender.url = "github:nixos/nixpkgs/cd76dbde7046b65b9acc83f059f651a2efb46fa6";
		nixpkgs-vncviewer.url = "github:nixos/nixpkgs/43f616a7cc2ee6c755c2860b0e974c255c911a13";
		nixpkgs-iterm2.url = "github:nixos/nixpkgs/4088596b40e68be2d75fb9a4a9f55d4a20034637";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
		nix-index-database.url = "github:nix-community/nix-index-database";
		nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
		home-manager.url = "github:nix-community/home-manager/release-24.05";
		home-manager.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = {
		self,
		darwin,
		nixpkgs,
		nixpkgs-unstable,
		nixpkgs-tailscale,
		nixpkgs-aldente,
		nixpkgs-bartender,
		nixpkgs-vncviewer,
		nixpkgs-iterm2,
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

		configuration = systemArg: darwin.lib.darwinSystem rec {
			system = systemArg;
			modules = darwinModules;
			specialArgs = {
				pkgs-tailscale = import nixpkgs-tailscale { inherit system; };

				pkgs-aldente = import nixpkgs-aldente {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-aldente.lib.getName pkg) [
						"aldente"
					];
				};

				pkgs-bartender = import nixpkgs-bartender {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-bartender.lib.getName pkg) [
						"bartender"
					];
				};

				pkgs-vncviewer = import nixpkgs-vncviewer {
					inherit system;

 					config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs-vncviewer.lib.getName pkg) [
						"realvnc-vnc-viewer"
					];
				};

				pkgs-iterm2 = import nixpkgs-iterm2 { inherit system; };
			};
		};
	in {
		darwinConfigurations = {
			adonis = configuration "aarch64-darwin";
			jason = configuration "aarch64-darwin";
			helenus = configuration "x86_64-darwin";
		};
	};
}

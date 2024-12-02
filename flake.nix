{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
		nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
		nixpkgs-tailscale.url = "github:nixos/nixpkgs/eb19b36ec45caf14e9fe5026d3970d89c03ced69";
		nixpkgs-aldente.url = "github:nixos/nixpkgs/db7dd707e17ac5d317ef4fd7924ce8820532952c";
		nixpkgs-bartender.url = "github:DimitarNestorov/nixpkgs/a548595bb3a3822fd27f73aa7c8be79ea762303b";
		nixpkgs-vncviewer.url = "github:nixos/nixpkgs/43f616a7cc2ee6c755c2860b0e974c255c911a13";
		nixpkgs-iterm2.url = "github:nixos/nixpkgs/4088596b40e68be2d75fb9a4a9f55d4a20034637";
		nixpkgs-sloth.url = "github:nixos/nixpkgs/2aee66095ca9cd6dfa78ca18ce79a1a5599e828c";
		nixpkgs-dbeaver.url = "github:nixos/nixpkgs/3c5a0228d9b4e6e233c22047d61ac6bd55e81661";
		nixpkgs-rapidapi.url = "github:nixos/nixpkgs/d3c3415edb84cd0c85512f7fd0def521b81966c1";
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
			pkgs-tailscale = import inputs.nixpkgs-tailscale { inherit system; };
			pkgs-iterm2 = import inputs.nixpkgs-iterm2 { inherit system; };
			pkgs-sloth = import inputs.nixpkgs-sloth { inherit system; };
			pkgs-dbeaver = import inputs.nixpkgs-dbeaver { inherit system; };
			pkgs-aldente = import inputs.nixpkgs-aldente {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"aldente"
				];
			};
			pkgs-bartender = import inputs.nixpkgs-bartender {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"bartender"
				];
			};
			pkgs-rapidapi = import inputs.nixpkgs-rapidapi {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"rapidapi"
				];
			};
			pkgs-vncviewer = import inputs.nixpkgs-vncviewer {
				inherit system;
				config.allowUnfreePredicate = pkg: builtins.elem (nixpkgs.lib.getName pkg) [
					"realvnc-vnc-viewer"
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
							tailscale = pkgs-tailscale.tailscale;
							aldente = pkgs-aldente.aldente;
							bartender = pkgs-bartender.bartender;
							realvnc-vnc-viewer = pkgs-vncviewer.realvnc-vnc-viewer;
							iterm2 = pkgs-iterm2.iterm2;
							sloth-app = pkgs-sloth.sloth-app;
							dbeaver-bin = pkgs-dbeaver.dbeaver-bin;
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

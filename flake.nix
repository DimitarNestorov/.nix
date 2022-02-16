{
	description = "System configuration";

	inputs = {
		nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-21.11-darwin";
		darwin.url = "github:lnl7/nix-darwin/master";
		darwin.inputs.nixpkgs.follows = "nixpkgs";
	};

	outputs = { self, darwin, nixpkgs }: 
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
	in {
		darwinConfigurations."Dimitars-MacBook-Pro" = darwin.lib.darwinSystem {
			modules = [ configuration ./configuration.nix ];
			inputs = { inherit darwin nixpkgs; };
			system = "aarch64-darwin";
		};

		darwinConfigurations."Dimitars-Mac-mini" = darwin.lib.darwinSystem {
			modules = [ configuration ./configuration.nix ];
			inputs = { inherit darwin nixpkgs; };
			system = "aarch64-darwin";
		};

		darwinConfigurations."Dimitars-Work-Hackintosh" = darwin.lib.darwinSystem {
			modules = [ configuration ./configuration.nix ];
			inputs = { inherit darwin nixpkgs; };
			system = "aarch64-darwin";
		};
	};
}

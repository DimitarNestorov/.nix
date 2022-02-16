{ stdenv, undmg, fetchurl }:
stdenv.mkDerivation rec {
	pname = "IINA";
	version = "1.2.0";

	buildInputs = [ undmg ];
	sourceRoot = ".";
	phases = [ "unpackPhase" "installPhase" ];

	src = fetchurl {
		url = "https://github.com/iina/iina/releases/download/v${version}/IINA.v${version}.dmg";
		sha256 = "sha256-kbh+gAVfCXoct6jJGXnetTAzFfIGdVLL5zh/SL/EJzY=";
	};

	installPhase = ''
		mkdir -p "$out/Applications/IINA.app"
		cp -r "IINA.app" "$out/Applications"
	'';

	meta = {
		platforms = [ "x86_64-darwin" "aarch64-darwin" ];
	};
}

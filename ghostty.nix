{ lib, stdenv, fetchurl, _7zz }:

stdenv.mkDerivation (finalAttrs: {
	pname = "ghostty";
	version = "1.0.0";

	src = fetchurl {
		url = "https://release.files.ghostty.org/${finalAttrs.version}/Ghostty.dmg";
		sha256 = "sha256-CR96Kz9BYKFtfVKygiEku51XFJk4FfYqfXACeYQ3JlI=";
	};

	nativeBuildInputs = [ _7zz ];
	
	sourceRoot = "Ghostty.app";
	installPhase = ''
		runHook preInstall

		mkdir -p "$out/Applications/${finalAttrs.sourceRoot}"
		cp -R . "$out/Applications/${finalAttrs.sourceRoot}"

		runHook postInstall
	'';

	meta = {
		homepage = "https://ghostty.org/";
		license = lib.licenses.mit;
		platforms = lib.platforms.darwin;
		sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
	};
})

{
  pkgs ? import <nixpkgs> { },
}:

pkgs.writeShellScriptBin "idof" ''
  	osascript -e "id of app \"$1\""
''

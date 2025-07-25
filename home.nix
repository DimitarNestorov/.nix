{
  config,
  lib,
  pkgs,
  type ? "personal",
  ...
}:
let
  vscode = pkgs.vscodium;

  configDir =
    {
      "vscode" = "Code";
      "vscode-insiders" = "Code - Insiders";
      "vscodium" = "VSCodium";
      "openvscode-server" = "OpenVSCode Server";
    }
    .${vscode.pname};

  vscodeUserDir =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/${configDir}/User"
    else
      "${config.xdg.configHome}/${configDir}/User";

  vscodeSettings = pkgs.writeText "settings.json" (
    builtins.toJSON (
      {
        "direnv.path.executable" = "/etc/profiles/per-user/dimitar/bin/direnv";
        "editor.accessibilitySupport" = "off";
        "editor.defaultFormatter" = "esbenp.prettier-vscode";
        "editor.fontFamily" = "JetBrainsMono Nerd Font";
        "editor.fontLigatures" = true;
        "editor.fontSize" = 16;
        "editor.formatOnSave" = true;
        "editor.insertSpaces" = false;
        "editor.minimap.enabled" = false;
        "editor.wordWrap" = "on";
        "extensions.autoCheckUpdates" = false;
        "extensions.autoUpdate" = false;
        "files.autoSave" = "onFocusChange";
        "git.autofetch" = true;
        "git.path" = "/run/current-system/sw/bin/git";
        "prettier.semi" = false;
        "prettier.tabWidth" = 4;
        "prettier.trailingComma" = "all";
        "prettier.useTabs" = true;
        "terminal.integrated.defaultProfile.osx" = "fish";
        "terminal.integrated.fontSize" = 15;
        "terminal.integrated.lineHeight" = 1.1;
        "terminal.integrated.profiles.osx" = {
          "bash" = {
            "path" = "bash";
            "args" = [ "-l" ];
            "icon" = "terminal-bash";
          };
          "zsh" = {
            "path" = "zsh";
            "args" = [ "-l" ];
          };
          "fish" = {
            "path" = "/etc/profiles/per-user/dimitar/bin/fish";
            "args" = [ "-l" ];
          };
        };
        "update.mode" = "none";
        "workbench.colorTheme" = "Visual Studio Light";
        "workbench.iconTheme" = "vscode-icons";
        "vsicons.dontShowNewVersionMessage" = true;
        "redhat.telemetry.enabled" = false;
        "nix.serverPath" = "${pkgs.nil}/bin/nil";
        "nix.enableLanguageServer" = true;
        "nix.serverSettings" = {
          "nil" = {
            "formatting" = {
              "command" = [ "${pkgs.nixfmt-rfc-style}/bin/nixfmt" ];
            };
          };
        };
        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
        "[xml]" = {
          "editor.defaultFormatter" = "esbenp.prettier-vscode";
        };
      }
      // (
        if type == "work" then
          { }
        else
          {
            "zig.path" = "${pkgs.zig}/bin/zig";
            "zig.zls.path" = "${pkgs.zls}/bin/zls";
            "zig.initialSetupDone" = true;
            "xml.java.home" = "${pkgs.jdk}";
          }
      )
    )
  );
in
{
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    grc
    terminal-notifier
    nano
    devenv
    nix-tree

    (import ./idof.nix { inherit pkgs; })
  ];

  programs.home-manager.enable = true;

  programs.direnv = {
    enable = true;

    nix-direnv.enable = true;
  };

  programs.fish = {
    enable = true;

    shellAliases = {
      darwin-rebuild-switch = "~/.nix/rebuild-and-switch.sh";
      ls = "colorls";
      code = "codium";
    };

    plugins = with pkgs.fishPlugins; [
      {
        name = "tide";
        src = tide.src;
      }
      {
        name = "grc";
        src = grc.src;
      }
      {
        name = "done";
        src = done.src;
      }
    ];

    functions = {
      fish_greeting = {
        description = "Greeting to show when starting a fish shell";
        body = "";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "Dimitar Nestorov";
    userEmail =
      if type == "work" then
        "dimitar.nestorov@callstack.com"
      else
        "8790386+dimitarnestorov@users.noreply.github.com";
    extraConfig = {
      core.editor = "/etc/profiles/per-user/dimitar/bin/nano";
      push.autoSetupRemote = true;
      push.default = "current";
    };
  };

  programs.htop.enable = true;

  home.activation.writableFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    cp ${vscodeSettings} "${vscodeUserDir}/settings.json"
    chmod u+w "${vscodeUserDir}/settings.json"
  '';

  programs.vscode = {
    enable = true;
    package = vscode;
    mutableExtensionsDir = false;
    extensions =
      with pkgs.vscode-extensions;
      [
        jnoortheen.nix-ide
        mhutchie.git-graph
        mkhl.direnv
        esbenp.prettier-vscode
        mikestead.dotenv
        vscode-icons-team.vscode-icons
        bradlc.vscode-tailwindcss
        yoavbls.pretty-ts-errors
        dbaeumer.vscode-eslint
      ]
      ++ (pkgs.vscode-utils.extensionsFromVscodeMarketplace [
        {
          name = "robotframework-lsp";
          publisher = "robocorp";
          version = "1.13.0";
          sha256 = "sha256-3hyKKAMUy4kXGRWBQCL4adV1W6xtgS1OYhJJYSzswbo=";
        }
      ])
      ++ (
        if type == "work" then
          [ ]
        else
          [
            redhat.vscode-xml
            ziglang.vscode-zig
            tauri-apps.tauri-vscode
            rust-lang.rust-analyzer
          ]
      );
    keybindings = [
      {
        key = "shift+cmd+g";
        command = "-workbench.action.terminal.findPrevious";
        when = "terminalFindFocused && terminalHasBeenCreated || terminalFindFocused && terminalProcessSupported || terminalFocus && terminalHasBeenCreated || terminalFocus && terminalProcessSupported";
      }
      {
        key = "shift+cmd+g";
        command = "-editor.action.previousMatchFindAction";
        when = "editorFocus";
      }
      {
        key = "shift+cmd+g";
        command = "workbench.view.scm";
        when = "workbench.scm.active";
      }
      {
        key = "ctrl+shift+g";
        command = "-workbench.view.scm";
        when = "workbench.scm.active";
      }
      {
        key = "ctrl+shift+-";
        command = "workbench.action.navigateBack";
      }
      {
        key = "ctrl+-";
        command = "-workbench.action.navigateBack";
      }
      {
        key = "ctrl+shift+-";
        command = "-workbench.action.navigateForward";
      }
    ];
  };

  xdg.configFile =
    let
      fishSetVars =
        vals:
        pkgs.lib.foldlAttrs (
          acc: name: value:
          acc + "set -u ${name} ${toString value}\n"
        ) "" vals;
    in
    {
      "fish/conf.d/add-nix-paths.fish".text = ''
        # This will prepend Home Manager and Nix Darwin paths but it will not prepend if we're in a Nix shell
        set filtered_path (string match -v '/nix/store/*-ghostty-*/*' $PATH)
        if not string match -q '/nix/store/*' (string join \n $filtered_path)
          set -x fish_user_paths /etc/profiles/per-user/$USER/bin /run/current-system/sw/bin
        end
      '';
      "fish/conf.d/tide-vars.fish".text = fishSetVars (import ./tide-config.nix);

      "ghostty/config" = {
        source = ./ghostty.conf;
      };
    };
}

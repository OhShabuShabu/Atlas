{
  description = "NixOS with home-manager btw";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    millennium.url = "github:SteamClientHomebrew/Millennium?dir=packages/nix";
    quickshell.url = "github:quickshell-mirror/quickshell";
    quickshell.inputs.nixpkgs.follows = "nixpkgs";
    awww.url = "git+https://codeberg.org/LGFae/awww";
    matugen = {
      url = "github:InioX/Matugen?ref=refs/tags/v3.1.0";
    };
    skwd-wall-src = {
      url = "github:liixini/skwd-wall";
      flake = false;
    };
    quicksnip-src = {
      url = "github:Ronin-CK/QuickSnip";
      flake = false;
    };
  };
  outputs = inputs @ { self, nixpkgs, home-manager, quickshell, ... }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      foreachSystem = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = foreachSystem (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          qsPkgs = quickshell.inputs.nixpkgs.legacyPackages.${system};
          
          quickshellWithModules = quickshell.packages.${system}.default.withModules (with qsPkgs.qt6; [
            qtmultimedia
            qtsvg
            qt5compat
            qtwayland
          ]);

          wallDeps = with pkgs; [
            matugen
            ffmpeg
            imagemagick
            inotify-tools
            sqlite
            jq
            curl
            file
            awww.packages.${system}.awww
          ];

          snipDeps = with pkgs; [
            grim
            imagemagick
            tesseract
            tesseract-data-eng
            wl-clipboard
            curl
            libnotify
            xdg-utils
            wlrctl
            wtype
          ];
        in {
          skwd-wall = pkgs.stdenv.mkDerivation {
            pname = "skwd-wall";
            version = "unstable";
            src = inputs.skwd-wall-src;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -p $out/share/skwd-wall
              cp -r . $out/share/skwd-wall
              mkdir -p $out/bin

              makeWrapper ${quickshellWithModules}/bin/quickshell $out/bin/skwd-wall-daemon \
                --prefix PATH : ${pkgs.lib.makeBinPath wallDeps} \
                --add-flags "-p $out/share/skwd-wall/daemon.qml"

              makeWrapper ${quickshellWithModules}/bin/quickshell $out/bin/skwd-wall-toggle \
                --add-flags "ipc -p $out/share/skwd-wall/daemon.qml call wallpaper toggle"
            '';
          };

          quicksnip = pkgs.stdenv.mkDerivation {
            pname = "quicksnip";
            version = "unstable";
            src = inputs.quicksnip-src;

            nativeBuildInputs = [ pkgs.makeWrapper ];

            installPhase = ''
              mkdir -p $out/share/quickshell/QuickSnip
              cp -r . $out/share/quickshell/QuickSnip
              mkdir -p $out/bin

              makeWrapper ${quickshellWithModules}/bin/quickshell $out/bin/quicksnip \
                --prefix PATH : ${pkgs.lib.makeBinPath snipDeps} \
                --set QUICKSHELL_CONFIG_DIR "$out/share" \
                --add-flags "-c" "QuickSnip" "-n"
            '';
          };
        });
      nixosConfigurations.atlas = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ 
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.yusa = import ./home.nix;
            };
          }
        ];
      };
    };
}
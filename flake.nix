{
  description = "WireGuard Mesh - Multi-geo VPN infrastructure via YSH";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
    flake-utils.url = "github:numtide/flake-utils";
    passveil.url = "github:doma-engineering/passveil";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      passveil,
      ...
    }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ] (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
        lib = pkgs.lib;

        # Runtime dependencies for the package
        runtimeDeps =
          with pkgs;
          [
            wireguard-tools
            oils-for-unix
            gum
            passveil.packages.${system}.passveil
            openssh
            curl
            jq
          ]
          ++ lib.optionals pkgs.stdenv.isDarwin [
            wireguard-go
          ];

        # The main wg-mesh package
        wg-mesh = pkgs.stdenv.mkDerivation {
          pname = "wg-mesh";
          version = "1.0.0";
          src = self;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            runHook preInstall

            # Create directories
            mkdir -p $out/bin
            mkdir -p $out/lib/wg-mesh
            mkdir -p $out/share/wg-mesh

            # Copy library files
            cp -r lib/*.ysh $out/lib/wg-mesh/

            # Copy bin scripts
            cp bin/*.ysh $out/share/wg-mesh/

            # Create wrapper scripts for each command
            for script in wg-setup wg-connect wg-status wg-switch uninstall-tunnelblick; do
              makeWrapper ${pkgs.oils-for-unix}/bin/ysh $out/bin/$script \
                --prefix PATH : ${lib.makeBinPath runtimeDeps} \
                --set WG_MESH_LIB $out/lib/wg-mesh \
                --add-flags "$out/share/wg-mesh/$script.ysh"
            done

            # Also create a wg-mesh wrapper for the main setup script
            makeWrapper ${pkgs.oils-for-unix}/bin/ysh $out/bin/wg-mesh \
              --prefix PATH : ${lib.makeBinPath runtimeDeps} \
              --set WG_MESH_LIB $out/lib/wg-mesh \
              --add-flags "$out/share/wg-mesh/wg-setup.ysh"

            runHook postInstall
          '';

          meta = with lib; {
            description = "Multi-geo WireGuard mesh VPN with TUI";
            homepage = "https://github.com/doma-engineering/feral-instinct";
            license = licenses.mit;
            platforms = platforms.unix;
            maintainers = [ ];
            mainProgram = "wg-mesh";
          };
        };
      in
      {
        # Installable packages
        packages = {
          default = wg-mesh;
          wg-mesh = wg-mesh;
        };

        # Development shell
        devShells.default = pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              # WireGuard - Core VPN tooling
              wireguard-tools

              # YSH (Oils for Unix) - Modern shell scripting
              oils-for-unix

              # TUI - Beautiful terminal UI components
              gum

              # Secrets management
              passveil.packages.${system}.passveil

              # Essential tools
              openssh
              curl
              git
              jq
              watch
              tree
              dnsutils

              # Script development tools
              shellcheck
              shfmt

              # Network diagnostics
              iperf3
              mtr
              nmap
            ]
            ++ lib.optionals pkgs.stdenv.isLinux [
              # Linux-specific networking tools
              iproute2
            ]
            ++ lib.optionals pkgs.stdenv.isDarwin [
              # macOS needs wireguard-go for userspace implementation
              wireguard-go
            ];

          shellHook = ''
            echo "WireGuard Mesh Development Environment"
            echo ""
            echo "Commands:"
            echo "  ysh bin/wg-setup.ysh wizard     - Setup provider accounts"
            echo "  ysh bin/wg-setup.ysh provision  - Create VPS instances"
            echo "  ysh bin/wg-setup.ysh deploy     - Deploy mesh configuration"
            echo "  ysh bin/wg-connect.ysh          - Connect to mesh VPN"
            echo "  ysh bin/wg-switch.ysh           - TUI route switcher"
            echo "  ysh bin/wg-status.ysh           - Show mesh status"
            echo ""
            echo "Installation:"
            echo "  nix profile install .           - Install to user profile"
            echo "  nix build                       - Build package"
            echo ""
          '';
        };
      }
    );
}

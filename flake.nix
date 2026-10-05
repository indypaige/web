{
  description = "indypaige.gay";

  inputs      = {
    page.url = "github:indypaige/page";
    nixpkgs.follows = "page/nixpkgs";
  };

  outputs     = { self, nixpkgs, page, ... }:
    let
      system = "x86_64-linux";
      pkgs   = import nixpkgs { inherit system; };

      rebuild = pkgs.writeShellApplication {
        name = "rebuild-site";

        runtimeInputs = with pkgs; [
          nix
          rsync
        ];

        text = ''
        set -euo pipefail
        target="''${1:-.#default}"
        echo "building $target..."
        nix build "$target"
        mkdir -p .serve
        rsync \
          --archive \
          --checksum \
          --delete \
          --chmod=Du=rwx,Dgo=rx,Fu=rw,Fgo=r \
          result/ \
          .serve/
        echo "rebuilt"
        '';
      };

      watch = pkgs.writeShellApplication {
        name = "watch";

        runtimeInputs = with pkgs; [
          rebuild
          watchexec
          miniserve
        ];

        text = ''
        set -euo pipefail
        target="''${1:-.#default}"
        port="''${PORT:-8080}"
        rebuild-site "$target"
        miniserve \
          --interfaces 127.0.0.1 \
          --port "$port" \
          --index index.html \
          --header "Cache-Control:no-store, no-cache, must-revalidate" \
          --header "Pragma:no-cache" \
          --header "Expires:0" \
          .serve &
        server_pid=$!
        cleanup() {
          kill "$server_pid" 2>/dev/null || true
        }
        trap cleanup EXIT INT TERM
        watchexec \
          --watch . \
          --ignore '.serve/**' \
          --ignore 'result' \
          --ignore 'result/**' \
        --shell=none \
        -- \
        rebuild-site "$target"
        '';
      };
    in {
      apps.${system}.watch = {
        type = "app";
        program = "${watch}/bin/watch";
      };

      packages.${system}.default = page.mk {
        page   = ./index.html;
        name   = "web";
        src    = self;

        static = [
          { copy = ./public/iosevka.woff; name = "iosevka.woff"; }
          { copy = ./public/htmx.min.js;  name = "htmx.min.js"; }
          { copy = ./public/indynet.png;  name = "indynet.png"; }
          { copy = ./public/styles.css;   name = "styles.css";  }
        ];
      };
    };
}

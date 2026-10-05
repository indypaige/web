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
    in {
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

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
      imgs   = builtins.attrNames (builtins.readDir ./public/gallery);
    in {
      packages.${system}.default = page.mk {
        page   = ./index.html;
        name   = "web";
        src    = self;

        static = [
          { copy = ./public/iosevka.woff; name = "iosevka.woff"; }
          { copy = ./public/htmx.min.js;  name = "htmx.min.js";  }
          { copy = ./public/indynet.png;  name = "indynet.png";  }
          { copy = ./public/styles.css;   name = "styles.css";   }
          { copy = ./public/gallery;      name = "gallery";      }
        ];

        pages.gallery = {
          page = ./gallery.html;
          env  = {
            images = map (x: "/static/gallery/" + x) imgs;
          };
        };

        pages.indy = {
          page = ./indy.html;
        };

        pages.hx = {
          page = ./hx/hx.html;

          pages.links.page = ./hx/links.html;
        };
      };
    };
}

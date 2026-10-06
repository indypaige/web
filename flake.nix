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

        ctx    = {
          year = 2026;
        };

        static = [
          { copy = ./public/hyperscript.min.js; name = "hyperscript.min.js"; }
          { copy = ./public/iosevka.woff;       name = "iosevka.woff";       }
          { copy = ./public/htmx.min.js;        name = "htmx.min.js";        }
          { copy = ./public/indynet.png;        name = "indynet.png";        }
          { copy = ./public/styles.css;         name = "styles.css";         }
          { copy = ./public/gallery;            name = "gallery";            }
        ];

        pages.gallery = {
          page = ./gallery/gallery.html;
          env  = {
            images = [ { path = "/static/gallery/talltree.jpg"; desc = "A tall tree I found walking to the gas station near my apartment in houston texas."; }
                     ];
          };

          pages.hx = {
            page = ./notfound.html;

            pages.modal.page = ./gallery/hx/modal.html;
          };
        };

        pages.indy = {
          page = ./indy.html;
        };

        pages.hx = {
          page = ./notfound.html;

          pages.links.page  = ./hx/links.html;
          pages.footer.page = ./hx/footer.html;
        };
      };
    };
}

{
  description = "indypaige.gay";

  inputs      = {
    page.url = "github:indypaige/page";
    nixpkgs.follows = "page/nixpkgs";
    oxb.url = "github:indypaige/oxb";
  };

  outputs     = { self, nixpkgs, page, oxb, ... }:
    let
      system = "x86_64-linux";
      pkgs   = import nixpkgs { inherit system; };
      export = oxb.packages.${system}.export ./blog.org;
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
                       { path = "/static/gallery/matcha.jpg";   desc = "Visited a local coffee shop in the center of houston. It was nice while it lasted."; }
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

        pages.blog = {
          page = "${export}/index.html";

          pages = let
            postsDir   = builtins.readDir "${export}/posts";
            postsPaths = builtins.attrNames postsDir;
            postsNames = map (x: let len = builtins.stringLength x;
                                 in builtins.substring 0 (len - 5) x) postsPaths;
            postsPages = map (x: {
              name       = x;
              value.page = "${export}/posts/${x}.html";
            }) postsNames;
          in builtins.listToAttrs postsPages;
        };
      };
    };
}

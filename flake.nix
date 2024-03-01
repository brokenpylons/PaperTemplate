{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        cache = pkgs.makeFontsCache {
          fontDirectories = pkgs.texlive.stix2-otf.pkgs;
        };
        config = pkgs.writeText "fonts.conf" ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <dir>${builtins.elemAt pkgs.texlive.stix2-otf.pkgs 0}</dir>
            <cachedir>${cache}</cachedir>
          </fontconfig>
        '';
        hasCurrentTime = builtins.hasAttr "currentTime" builtins;
      in
      {
        packages = {
          default = self.packages.${system}.paper;

          paper = with pkgs; stdenv.mkDerivation {
            pname = "paper";
            version = "0.0.0";
            src = ./src;

            TEXMFVAR = "/tmp/texmf";
            SOURCE_DATE_EPOCH = builtins.currentTime or 0;

            preBuild = ''
              mkdir -p $TEXMFVAR
            '';

            installPhase = ''
              mkdir -p $out
              cp paper.pdf $out
            '';

            FONTCONFIG_FILE = config;

            buildInputs = [
              (texlive.combine {
                inherit (texlive) scheme-small luatex biblatex latexmk biber lualatex-math stix2-otf;
              })
            ];
          };
        };
      });
}

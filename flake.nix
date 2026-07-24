{
  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      self,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      perSystem =
        {
          system,
          ...
        }:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          tex = pkgs.texlive.combine {
            inherit (pkgs.texlive)
              accsupp
              adjustbox
              biblatex
              changepage
              cmap
              dashrule
              enumitem
              epstopdf-pkg
              etoolbox
              everyshi
              extsizes
              fontawesome5
              fontaxes
              fontspec
              geometry
              hyperref
              ifmtarg
              iftex
              infwarerr
              latex-bin
              latexmk
              lato
              ltxcmds
              luatex85
              luatexbase
              multirow
              paracol
              pdftexcmds
              pdfx
              pgf
              roboto
              scheme-minimal
              simpleicons
              tcolorbox
              tikzfill
              xcolor
              xmpincl
              ;
          };
        in
        {
          packages = {
            default = pkgs.stdenvNoCC.mkDerivation rec {
              name = "latex-cv";
              src = self;
              buildInputs = [
                pkgs.coreutils
                pkgs.route159
                tex
              ];
              phases = [
                "unpackPhase"
                "buildPhase"
                "installPhase"
              ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                env HOME=$(mktemp -d) OSFONTDIR=${pkgs.route159}/share/fonts \
                SOURCE_DATE_EPOCH=$(date -d "2026-07-27" +%s) \
                latexmk -interaction=nonstopmode -pdf -lualatex \
                -pretex="\pdfvariable suppressoptionalinfo 512\relax" \
                -usepretex main.tex
              '';
              installPhase = ''
                mkdir -p $out
                cp main.pdf $out/
              '';
            };
          };
        };
    };
}

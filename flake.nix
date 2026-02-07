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
              infwarerr
              latex-bin
              latexmk
              lato
              ltxcmds
              multirow
              paracol
              pdftexcmds
              pdfx
              pgf
              roboto
              scheme-minimal
              tcolorbox
              tikzfill
              xcolor
              xmpincl
              changepage
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
                pkgs.fira-code
                tex
              ];
              phases = [
                "unpackPhase"
                "buildPhase"
                "installPhase"
              ];
              buildPhase = ''
                export PATH="${pkgs.lib.makeBinPath buildInputs}";
                mkdir -p .cache/texmf-var
                env TEXMFHOME=.cache TEXMFVAR=.cache/texmf-var \
                SOURCE_DATE_EPOCH=$(date -d "2025-02-07" +%s) \
                latexmk -interaction=nonstopmode -pdf -pdflatex \
                -pretex="\pdftrailerid{}" \
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

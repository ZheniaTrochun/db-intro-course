{
  description = "A Nix devShell";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = {nixpkgs, ...}: let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        git
        gnumake

        docker
        docker-compose

        prisma-engines
        prisma
        prisma-language-server

        bun

        # LSPs
        dockerfile-language-server
        typescript-language-server
      ];

      shellHook = ''
        export PKG_CONFIG_PATH="${pkgs.openssl.dev}/lib/pkgconfig"
        export PRISMA_SCHEMA_ENGINE_BINARY="${pkgs.prisma-engines}/bin/schema-engine"
        export PRISMA_QUERY_ENGINE_BINARY="${pkgs.prisma-engines}/bin/query-engine"
        export PRISMA_FMT_BINARY="${pkgs.prisma-engines}/bin/prisma-fmt"
        export PATH="/home/crocoby/.bun/bin:$PATH"
        echo Welcome to devShell!
      '';
    };
  };
}


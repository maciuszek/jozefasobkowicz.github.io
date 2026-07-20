{
  description = "Dev shell for the Jozefa Sobkowicz memorial Jekyll site";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in {
        devShells.default = pkgs.mkShell {
          # Ruby + the C toolchain and libraries that Jekyll's native gems
          # (ffi, sassc) need to compile from source on NixOS.
          packages = with pkgs; [
            ruby_3_3
            bundler
            gcc
            gnumake
            pkg-config
            libffi
            zlib
            libyaml
          ];

          shellHook = ''
            # Keep gems inside the project so nothing touches the system.
            export BUNDLE_PATH="$PWD/vendor/bundle"
            export BUNDLE_BUILD__SASSC="--disable-lto"
            # Force native gems to build from source instead of pulling
            # precompiled binaries that won't run on NixOS.
            export BUNDLE_FORCE_RUBY_PLATFORM=true
            export GEM_HOME="$BUNDLE_PATH"
            export PATH="$BUNDLE_PATH/bin:$PATH"

            echo "Jozefa site dev shell ready."
            echo "First time:   bundle install"
            echo "Preview:      bundle exec jekyll serve --livereload"
            echo "Then open:    http://localhost:4000"
          '';
        };
      });
}

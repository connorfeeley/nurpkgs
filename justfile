#!/usr/bin/env -S just --justfile

set dotenv-load # Use direnv
set export # All arguments are exported to environment

bt := '0'
log := "warn"
export RUST_BACKTRACE := bt
export JUST_LOG := log

alias e := eval
alias b := build
alias t := test

# fzf prompt
default:
  @just --choose

# evaluate
eval:
  echo "Evaluating..."
  nix-env -f . -qa \* --meta --json \
      --allowed-uris https://static.rust-lang.org \
      --option restrict-eval false \
      --option allow-import-from-derivation true \
      --show-trace \
      --drv-path --show-trace \
      -I nixpkgs=$(nix-instantiate --find-file nixpkgs) \
      -I $PWD

# build all outputs
build:
  echo "Building..."
  nix shell -f '<nixpkgs>' nix-build-uncached -c nix-build-uncached --show-trace ci.nix -A cacheOutputs

test: eval build

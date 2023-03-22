# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, Accelerate ? null }:

stdenv.mkDerivation {
  pname = "llama-cpp";
  version = "2023-03-17";

  src = fetchFromGitHub {
    owner = "antimatter15";
    repo = "alpaca.cpp";
    rev = "da0e9fe90ccf6e73597eb19dd0cfc0a28363fb3b";
    hash = "sha256-LwwAwoKug1DawfCirW6qQkyifhONH/5OfjM7p9QQ9mM=";
  };

  nativeBuildInputs = [ cmake pkg-config ] ++
    lib.optionals stdenv.isDarwin [ Accelerate ];

  # Dot product data manipulation instructions are supported on apple silicon
  cmakeFlags = lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
    "-DCMAKE_C_FLAGS=-D__ARM_FEATURE_DOTPROD=1"
  ] ++
  [ "-DLLAMA_ALL_WARNINGS=OFF" ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 bin/llama bin/quantize $out/bin
  '';

  meta = with lib; {
    description = "Locally run an Instruction-Tuned Chat-Style LLM";
    mainProgram = "llama";
    license = licenses.mit;
    maintainers = [ maintainers.cfeeley ];
    platforms = platforms.all;
  };
}

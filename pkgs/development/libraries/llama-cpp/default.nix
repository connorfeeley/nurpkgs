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
    rev = "235a4115dfe50c63a0290ffb6c70719c9a9341e";
    hash = "sha256-HQ5ybgaaJ60HTJESmQP7e0gXIaYv2beoue/Lt+yXfl0=";
  };

  nativeBuildInputs = [ cmake pkg-config ] ++
    lib.optionals stdenv.isDarwin [ Accelerate ];

  # Dot product data manipulation instructions are supported on apple silicon
  cmakeFlags = lib.optionals (stdenv.isDarwin && stdenv.isAarch64) [
    "-DCMAKE_C_FLAGS=-D__ARM_FEATURE_DOTPROD=1"
  ];

  installPhase = ''
    mkdir -p $out/bin
    install -m755 chat quantize $out/bin
    install -m755 libggml.a $out/lib
  '';

  meta = with lib; {
    description = "Locally run an Instruction-Tuned Chat-Style LLM";
    license = licenses.mit;
    maintainers = [ maintainers.cfeeley ];
    platforms = platforms.all;
  };
}

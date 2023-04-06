# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, stdenv, fetchFromGitHub, cmake, pkg-config, Accelerate ? null }:

stdenv.mkDerivation {
  pname = "llama-cpp";
  version = "2023-04-06";

  src = fetchFromGitHub {
    owner = "antimatter15";
    repo = "alpaca.cpp";
    rev = "a0c74a70194284e943020cb43d8072a048aaeec5";
    hash = "sha256-1WyqOhq3MjnVevqgQALKE8+AvET1kQYo7wXuSG6ZpmE=";
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
    install -m755 chat quantize $out/bin
    install -m755 libggml.a $out/lib
  '';

  meta = with lib; {
    description = "Locally run an Instruction-Tuned Chat-Style LLM";
    mainProgram = "chat";
    license = licenses.mit;
    maintainers = [ maintainers.cfeeley ];
    platforms = platforms.all;
  };
}

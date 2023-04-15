# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ lib, newScope, pkgs }:

lib.makeScope newScope (self: let inherit (self) callPackage; in {
  aranet4 = callPackage ./pkgs/development/python-modules/aranet4 { };
  auto-gpt = callPackage ./pkgs/development/python-modules/auto-gpt { };
  broadcastify-archtk = callPackage ./pkgs/development/python-modules/broadcastify-archtk { };
  duckduckgo-search = callPackage ./pkgs/development/python-modules/duckduckgo-search { };
  g-tts = callPackage ./pkgs/development/python-modules/gTTS { };
  webdriver-manager = callPackage ./pkgs/development/python-modules/webdriver-manager { };
  pinecone-client = callPackage ./pkgs/development/python-modules/pinecone-client { };
  sourcery = callPackage ./pkgs/development/python-modules/sourcery { };
  tiktoken = callPackage ./pkgs/development/python-modules/tiktoken { };
})

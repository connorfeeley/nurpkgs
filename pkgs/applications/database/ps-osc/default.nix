# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: BSD-3-Clause

{ bundlerApp }:

let gemdir = ./.;
in bundlerApp {
  pname = "pg_online_schema_change";
  inherit gemdir;
  exes = [ "pg-online-schema-change" ];
}

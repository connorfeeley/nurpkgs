# SPDX-FileCopyrightText: 2023 Connor Feeley
#
# SPDX-License-Identifier: MIT

final: prev: {
  lib = prev.lib.extend (final: prev: {
    maintainers = prev.maintainers // {
      cfeeley = {
        email = "git@cfeeley.org";
        github = "connorfeeley";
        githubId = 676409;
        name = "Connor Feeley";
        keys = [{
          fingerprint = "6903 7A8C 3B70 36FF A2F8  AFFF 77CB 2390 C53B 4E5B";
        }];
      };
    };
  });
}

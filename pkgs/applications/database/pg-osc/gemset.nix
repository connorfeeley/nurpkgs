{
  google-protobuf = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1dq5lgkxhagqr8zjrwr10zi8rldbg2vhis2m5q86v5q9415ylfgj";
      type = "gem";
    };
    version = "3.23.4";
  };
  oj = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ghii2zb14rri5jdpvgh29c2lpnl777nkcirdy698qlmpzxasz7d";
      type = "gem";
    };
    version = "3.14.2";
  };
  ougai = {
    dependencies = ["oj"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0zmngsm3lrliscry7ljw7x5gnf3m4cn4kdgnxccaidhwj0mm539f";
      type = "gem";
    };
    version = "2.0.0";
  };
  pg = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "10ryzmc3r5ja6g90a9ycsxcxsy5872xa1vf01jam0bm74zq3zmi6";
      type = "gem";
    };
    version = "1.3.5";
  };
  pg_online_schema_change = {
    dependencies = ["ougai" "pg" "pg_query" "thor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lgz56gcy6km0gy802r7aprg7ar7iidrrya3i72i8qr9ch0s64c7";
      type = "gem";
    };
    version = "0.7.5";
  };
  pg_query = {
    dependencies = ["google-protobuf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fyhhb5f2y5mqk5vg5ykicxp58wwhc7invfp27x8d7fgi0zkdwa8";
      type = "gem";
    };
    version = "2.1.4";
  };
  thor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0k7j2wn14h1pl4smibasw0bp66kg626drxb59z7rzflch99cd4rg";
      type = "gem";
    };
    version = "1.2.2";
  };
}

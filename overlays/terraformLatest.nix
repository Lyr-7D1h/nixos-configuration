final: prev: {
  terraformLatest = final.terraform_0_14;

  terraform_0_14 = prev.terraform_0_14.overrideAttrs (old: rec {
    name = "terraform-${version}";
    version = "0.14.4";
    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = "terraform";
      rev = "v${version}";
      sha256 = "0kjbx1gshp1lvhnjfigfzza0sbl3m6d9qb3in7q5vc6kdkiplb66";
    };
  });
  terraform_latest = prev.terraform.overrideAttrs (old: rec {
    name = "terraform-${version}";
    version = "1.0.11";
    src = prev.fetchFromGitHub {
      owner = "hashicorp";
      repo = "terraform";
      rev = "v${version}";
      sha256 = "0k05s4zm16vksq21f1q00y2lzfgi5fhs1ygydm8jk0srs9x8ask7";
    };
  });
}

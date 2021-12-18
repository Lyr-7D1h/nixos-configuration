final: prev: {
  torbrowserLatest = prev.torbrowser.overrideAttrs (old: rec {
    name = "torbrowser-${version}";
    version = "11.0.2";
    srcs = {
      x86_64-linux = fetchurl {
        urls = [
          "https://dist.torproject.org/torbrowser/${version}/tor-browser-linux64-${version}_${lang}.tar.xz"
          "https://tor.eff.org/dist/torbrowser/${version}/tor-browser-linux64-${version}_${lang}.tar.xz"
        ];
        sha256 = "ba402bd5e7fcbe1281d2d18f31f64e20c68229f303bafa12bd4d24481b5a14af";
      };
    };
  });
}

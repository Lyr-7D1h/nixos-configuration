final: prev: {
  firefox-dev = prev.firefox-devedition-bin.overrideAttrs (old: rec {
    name = "firefox-dev";
    postInstall = ''
      mv $out/bin/firefox $out/bin/firefox-dev
    '';
  });
}

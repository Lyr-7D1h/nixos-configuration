{ nixpkgs, pkgs, ... }:
{
  environment.systemPackages = [ pkgs.macchanger ];
  systemd.services."macchanger" = {
    description = "Changes MAC address";
    wants = [ "network-pre.target" ];
    wantedBy = [ "multi-user.target" ];
    before = [ "network-pre.target" ];
    bindsTo = [ "sys-subsystem-net-devices-wlp3s0.device" ];
    after = [ "sys-subsystem-net-devices-wlp3s0.device" ];
    script = ''
      ${pkgs.macchanger}/bin/macchanger -e enp39s0
    '';
    serviceConfig.Type = "oneshot";
  };
}

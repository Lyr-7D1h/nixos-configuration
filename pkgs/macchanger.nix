{ nixpkgs, pkgs, ... }:
let device = "enp39s0"; in 
{
  environment.systemPackages = [ pkgs.macchanger ];
  # systemd.services.macchanger = {
  #    enable = true;
  #    description = "macchanger on ${device}";
  #    wants = [ "network-pre.target" ];
  #    wantedBy = [ "multi-user.target" ];
  #    before = [ "network-pre.target" ];
  #    bindsTo = [ "sys-subsystem-net-devices-${device}.device" ];
  #    after = [ "sys-subsystem-net-devices-${device}.device" ];
  #    serviceConfig = {
  #      Type = "oneshot";
  #      ExecStart = "${pkgs.macchanger}/bin/macchanger -r ${device}";
  #    };
  #    # reloadIfChanged = false;
  #    restartIfChanged = false;
  #  };
}

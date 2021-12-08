{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gnome.dconf-editor
    gnomeExtensions.appindicator
    gnomeExtensions.caffeine
    gnomeExtensions.gsconnect
  ];
  services.xserver.enable = true;
  services.udev.packages = with pkgs; [ gnome3.gnome-settings-daemon ];
  environment.gnome.excludePackages = with pkgs.gnome; [ geary music ];
  services.xserver.desktopManager.gnome = {
    enable = true;
    extraGSettingsOverridePackages = with pkgs; [ gnome3.gnome-settings-daemon ];
    extraGSettingsOverrides = ''
        [org/gnome/settings-daemon/plugins/media-keys]
        custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']
        screensaver=['<Shift><Super>underscore']
        www=@as []

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
        binding='<Super>Return'
        command='gnome-terminal'
        name='Gnome Terminal'
    '';
  };
  services.xserver.displayManager.gdm.enable = true;
}

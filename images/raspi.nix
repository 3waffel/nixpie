{
  lib,
  nixos-hardware,
  ...
}: {
  nixpkgs.localSystem = {
    config = "aarch64-unknown-linux-gnu";
    system = "aarch64-linux";
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };
  swapDevices = [];

  powerManagement.cpuFreqGovernor = lib.mkDefault "ondemand";

  networking.wireless.enable = false;

  hardware.pulseaudio.enable = false;

  documentation.enable = false;
}

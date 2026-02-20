# nix/machines/neptune/disko.nix
{ ... }:

{
  disko.devices = {
    disk = {
      system = {
        type = "disk";
        device = "/dev/disk/by-id/nvme-Samsung_SSD_980_500GB_S64ENG0R303947W";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              name = "disk-system-esp";
              size = "1G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };

            swap = {
              name = "disk-system-swap";
              size = "16G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };

            root = {
              name = "disk-system-root";
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}

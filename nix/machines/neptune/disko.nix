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
      # Samsung 860 EVO 500GB – pool named after hardware, dataset after purpose (like toshiba14T)
      samsung860evo500 = {
        type = "disk";
        device = "/dev/disk/by-id/ata-Samsung_SSD_860_EVO_500GB_S3Z1NB0K921361E";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "samsung860evo500";
              };
            };
          };
        };
      };
    };
    zpool = {
      samsung860evo500 = {
        type = "zpool";
        options.cachefile = "none";
        rootFsOptions = {
          compression = "off";
        };
        datasets = {
          rds = {
            type = "zfs_fs";
            mountpoint = "/var/lib/rds";
            options = {
              recordsize = "8k";
              compression = "off";
            };
          };
        };
      };
    };
  };
}

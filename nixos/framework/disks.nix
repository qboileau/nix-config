
{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/nvme0n1";
        type = "disk";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              name = "ESP";
              type = "EF00";
              size = "1000M";
              label = "ESP";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "fmask=0022" "dmask=0022"  ];
              };
            };
            #plainSwap = {
            #  size = "69G";
            #  content = {
            #    type = "swap";
            #    discardPolicy = "both";
            #    resumeDevice = true; # resume from hiberation from this device
            #  };
            #};
            luks = {
              name="crypted-nixos";
              size = "100%";
              label = "crypted-nixos";
              content = {
                type = "luks";
                name = "crypted";
                askPassword = true;
                initrdUnlock = true;
                # disable settings.keyFile if you want to use interactive password entry
                # passwordFile = "/tmp/secret.key"; # Interactive
                settings = {
                  allowDiscards = true;
                };
                content = {
                 type = "btrfs";
                  extraArgs = [ "-L" "nixos" "-f" ];
                  subvolumes = {
                    "/root" = {
                      mountpoint = "/";
                      mountOptions = [ "subvol=root" "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "subvol=home" "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "subvol=nix" "compress=zstd" "noatime" ];
                    };
                    # get swap offset with : btrfs inspect-internal map-swapfile -r /swap
                    "/swap" = {
                      mountpoint = "/swap";
                      swap.swapfile.size = "69G";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
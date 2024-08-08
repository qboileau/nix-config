
{ lib, ... }:

{
  disko.devices = {
    disk = {
      main = {
        device = "/dev/sda";
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
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/home" = {
                      mountpoint = "/home";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/nix" = {
                      mountpoint = "/nix";
                      mountOptions = [ "compress=zstd" "noatime" ];
                    };
                    "/swap" = {
                      mountpoint = "/.swapvol";
                      swap.swapfile.size = "20M";
                    };
                  };
                };
              };
            };

            # root = {
            #   name = "nixos";
            #   size = "90%";
            #   label = "nixos";
            #   content = {
            #     type = "btrfs";
            #     extraArgs = [ "-L" "nixos" "-f" ]; # Override existing partition
            #     mountpoint = "/";
            #     mountOptions = [ "subvol=@" "compress=zstd" "noatime" ];
            #   };
            # };

          };
        };
      };
    };
  };
}
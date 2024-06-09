{ inputs, ... }@flakeContext:
let
  netboot = { config, lib, pkgs, ... }: {
    imports = [
      ../repo/modules/services/openmesh/xnode/admin.nix
    ];
    config = {
      documentation = {
        nixos = {
          enable = false;
        };
        doc = {
          enable = false;
        };
      };
      services = {
        openmesh = {
          xnode = {
            admin = {
              enable = true;
              remoteDir = "https://dpl-backend-staging.up.railway.app/xnodes/functions";
            };
          };
        };
        getty = {
          greetingLine = ''<<< Welcome to Openmesh XnodeOS ${config.system.nixos.label} (\m) - \l >>>'';
          autologinUser = lib.mkForce "xnode";
        };
      };
      environment = {
        systemPackages = with pkgs; [
          nyancat
        ];
      };
      netboot = {
        squashfsCompression = "gzip -Xcompression-level 1";
      };
      boot = {
        postBootCommands = ''nixos-generate-config; echo '{config,lib,pkgs,...}:{imports=[./hardware-configuration.nix] ++ lib.optional (builtins.pathExists /home/xnode/config.nix) /home/xnode/config.nix; boot.loader.grub.enable=false;}' > /etc/nixos/configuration.nix'';
        # Fixme: Hardcoded import location /var/lib/openmesh-xnode-admin/config.nix
      };
      networking = {
        hostName = "xnode";
      };
      users = {
        users = {
          xnode = {
            isNormalUser = true;
            password = "xnode";
            extraGroups = [ "wheel" ];
          };
        };
      };
    };
  };
in
inputs.nixos-generators.nixosGenerate {
  system = "x86_64-linux";
  customFormats = { "netboot" = import ./custom-formats/netboot.nix; };
  format = "netboot";
  modules = [
    netboot
  ];
}

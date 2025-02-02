{ config, lib, pkgs, ... }: {
    config = {
      nix.settings.experimental-features = [ "nix-command" "flakes" ];
      nix.settings.trusted-users = [ "@wheel" ];
      nix.settings.auto-optimise-store = true;

      system.defaultChannel = "https://github.com/Openmesh-Network/Xnodepkgs/archive/dev.tar.gz";
      system.stateVersion = "24.11";

      documentation.nixos.enable = false;
      documentation.doc.enable = false;

      services.openmesh.xnode.admin.enable = true;
      services.openmesh.xnode.admin.remoteDir = "https://dpl-staging.openmesh.network/xnodes/functions";

      services.openssh.enable = lib.mkForce false;

      users.motd = null;
      users.users.xnode = {
        isNormalUser = true;
        extraGroups = [ "wheel" ];
      };
      security.sudo.wheelNeedsPassword = false;

      services.getty = {
        autologinUser = lib.mkForce "xnode";
        helpLine = lib.mkForce ''\n'';
        greetingLine = ''<<< Welcome to Openmesh XnodeOS ${config.system.nixos.label} (\m) - \l >>>'';
      };

      networking = {
        hostName = lib.mkDefault "xnode";
      };

      boot = {
        postBootCommands = ''
                            cat > /etc/nixos/configuration.nix <<ENDFILE
                            {config, lib, pkgs, ...}:{
                              imports=[./hardware-configuration.nix] ++ lib.optional (builtins.pathExists /var/lib/openmesh-xnode-admin/config.nix) /var/lib/openmesh-xnode-admin/config.nix ++ lib.optional (builtins.pathExists /var/lib/openmesh-xnode-admin/xnodeos) /var/lib/openmesh-xnode-admin/xnodeos/repo/modules/services/openmesh/xnode/admin.nix ;
                              config = {
                                nix.settings.experimental-features = [ "nix-command" "flakes" ];
                                nix.settings.trusted-users = [ "@wheel" ];
                                nix.settings.auto-optimise-store = true;
                                nix.gc.automatic = true;
                                nix.gc.dates = "hourly";
                                nix.gc.randomizedDelaySec = "15min";
                                nix.gc.options = "--delete-old +1 --delete-older-than 1d";

                                nixpkgs.config.allowUnfree = true;

                                system.defaultChannel = "https://github.com/Openmesh-Network/Xnodepkgs/archive/dev.tar.gz";
                                system.stateVersion = "24.11";

                                services.openmesh.xnode.admin.enable = true;
                                services.openmesh.xnode.admin.remoteDir = "https://dpl-staging.openmesh.network/xnodes/functions";

                                services.openssh.enable = lib.mkDefault false;

                                documentation.nixos.enable = false;
                                documentation.doc.enable = false;

                                boot.loader.grub.enable=false;

                                users.motd = null;
                                users.users.xnode = {
                                  isNormalUser = true;
                                  extraGroups = [ "wheel" ];
                                };
                                security.sudo.wheelNeedsPassword = false;

                                services.getty = {
                                  autologinUser = lib.mkForce "xnode";
                                  helpLine = lib.mkForce ''\'''\'\n''\'''\';
                                  greetingLine = ''\'''\'<<< Welcome to Openmesh XnodeOS ${config.system.nixos.label} (\m) - \l >>>''\'''\';
                                };

                                networking = {
                                  hostName = "xnode";
                                };
                            ENDFILE

                            echo "''$(cat /proc/cmdline | ${pkgs.gnugrep}/bin/grep -oE 'XNODE_CONFIG_EXTRA=([a-zA-Z0-9+=/]*)' | cut -d= -f2- | base64 -d)" >> /etc/nixos/configuration.nix

                            cat >> /etc/nixos/configuration.nix <<ENDFILE
                              };
                            }
                            ENDFILE

                            cat > /etc/nixos/hardware-configuration.nix <<ENDFILE
                            {config, lib, pkgs, modulesPath, ...}: {
                              fileSystems = {
                                "/" = {
                                  device = "none";
                                  fsType = "tmpfs";
                                };
                              };
                              nixpkgs.hostPlatform=lib.mkDefault "x86_64-linux";
                            ENDFILE

                            echo "''$(cat /proc/cmdline | ${pkgs.gnugrep}/bin/grep -oE 'XNODE_HARDWARE_CONFIG_EXTRA=([a-zA-Z0-9+=/]*)' | cut -d= -f2- | base64 -d)" >> /etc/nixos/hardware-configuration.nix

                            cat >> /etc/nixos/hardware-configuration.nix <<ENDFILE
                            }
                            ENDFILE
                          '';
      };
    };
  }

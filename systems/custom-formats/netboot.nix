{modulesPath, pkgs, config, ... }: {

  imports = [
    "${toString modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  system.build = rec {
    image = pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
      mkdir $out
      cp ${config.system.build.kernel}/${config.system.boot.loader.kernelFile} $out/kernel
      cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
      cp ${config.system.build.ipxe_test_entrypoint_script} $out/ipxe_test_entrypoint
      cp ${config.system.build.ipxe_integration_script} $out/ipxe_integration_script
      cp ${config.system.build.ipxe_script} $out/ipxe
      echo "init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams}" > $out/cmdline

      nuke-refs $out/kernel
    '';
    xnode_version = "0";
    xnode_uuid = "AKD758Z8RB-QIW5D9STYK";
    xnode_access_token = "3YT6cBGkYE+QMk+3sONySrnC4q/1A13cEtZHk2oHE1u+9/ef84modZWQjPqxUdbU2xy+TGxKOAMYkjDLPXNkeA==";
    xnode_config_remote = "https://dpl-backend-staging.up.railway.app/xnodes/functions/";

    ipxe_test_entrypoint_script = pkgs.writeTextFile {
      executable = false;
      name = "ipxe_test_entrypoint";

      text = ''
        #!ipxe
        set xnode_version 0
        set xnode_extra_kernel_cmdline XNODE_EXTRA_KERNEL_CMDLINE_TEST=1
        set xnode_uuid ${xnode_uuid}
        set xnode_access_token ${xnode_access_token}
        set xnode_config_remote ${xnode_config_remote}
        set integration_chain_url http://127.0.0.1:8000/ipxe_integration_script
        set os_loader_chain_url http://127.0.0.1:8000/ipxe
        set kernel_url http://127.0.0.1:8000/kernel
        set initrd_url http://127.0.0.1:8000/initrd
        isset ''${integration_chain_url} && chain ''${integration_chain_url} ||
        chain ''${os_loader_chain_url}
      '';
    };

    ipxe_integration_script = pkgs.writeTextFile {
      executable = false;
      name = "ipxe_integration_script";

      text = ''
        #!ipxe
        clear integration_chain_url

        set xnode_integration_version 0

        # example base64'd "# Empty Hardware Integration Script" w/o newline
        set xnode_hardware_config_extra yBFbXB0eSBIYXJkd2FyZSBJbnRlZ3JhdGlvbiBTY3JpcHQ=

        isset ''${integration_chain_url} && chain ''${integration_chain_url} ||
        chain ''${os_loader_chain_url}
      '';
    };

    ipxe_script = pkgs.writeTextFile {
      executable = false;
      name = "ipxe";
      text = ''
        #!ipxe
        # Admin Service Expects the following to be set for initialisation in the chainloading iPXE script:
        #   - xnode_version
        #   - xnode_uuid
        #   - xnode_access_token
        kernel ''${kernel_url} initrd=initrd init=${builtins.unsafeDiscardStringContext config.system.build.toplevel}/init ${toString config.boot.kernelParams} -- XNODE_VERSION=''${xnode_version} XNODE_UUID=''${xnode_uuid} XNODE_ACCESS_TOKEN=''${xnode_access_token} XNODE_CONFIG_REMOTE=''${xnode_config_remote} XNODE_INTEGRATION_VERSION=''${xnode_integration_version} XNODE_HARDWARE_CONFIG_EXTRA=''${xnode_hardware_config_extra} ''${xnode_extra_kernel_cmdline} AVOID_NEWLINE=1
        initrd ''${initrd_url}
        boot
      '';
    };

  };

  boot.kernelParams = [
    "console=ttyS0,115200" # allows certain forms of remote access, if the hardware is setup right
    "panic=30"
    "boot.panic_on_fail" # reboot the machine upon fatal boot issues
  ];

  formatAttr = "image";
}

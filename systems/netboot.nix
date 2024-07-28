{ inputs, ... }@flakeContext:
let
  config.netboot = {
    squashfsCompression = "zstd -Xcompression-level 15";
  };
  netboot = import ./xnode-common.nix;
in
inputs.nixos-generators.nixosGenerate {
  system = "x86_64-linux";
  customFormats = { "netboot" = import ./custom-formats/netboot.nix; };
  format = "netboot";
  modules = [
    ({ ... }: { nix.registry.nixpkgs.flake = inputs.nixpkgs; })
    netboot
  ];
}

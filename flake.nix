{
  description = "Xnode OS";
  inputs = {
    nixpkgs.url = "github:j-openmesh/Xnodepkgs/feature/xnode-personaliser";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = inputs:
    let
      flakeContext = {
        inherit inputs;
      };
    in
    {
      packages = {
        x86_64-linux = {
          iso = import ./systems/iso.nix flakeContext;
          netboot = import ./systems/netboot.nix flakeContext;
          kexec = import ./systems/kexec.nix flakeContext;
        };
      };
    };
}

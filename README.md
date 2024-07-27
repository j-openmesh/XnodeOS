# XnodeOS
XnodeOS is a modularised opinionated-yet-configurable operating system for Xnodes based on NixOS.

## building
1. `make clean`, optionally
2. `make iso` or `make netboot` or `make kexec`

## requirements
You must have the nix package installed for this build to work.

## testing netboot
```
make clean netboot
cd result
python3 -m http.server&
qemu-system-x86_64 -nographic -enable-kvm -m 16G -cpu max -serial mon:stdio -net user,bootfile="http://127.0.0.1:8000/ipxe_test_entrypoint" -net nic -msg timestamp=on
```

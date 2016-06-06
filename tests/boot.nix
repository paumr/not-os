{ system }:

with import <nixpkgs/nixos/lib/testing.nix> { inherit system; };

let
  config = (import ./.. { extraModules = [ ./test-instrumentation.nix ]; }).config;
in
{
  ipxeCrypto = makeTest {
    name = "ipxe-crypto";
    nodes = {};
    testScript = ''
      my $machine = createMachine({ qemuFlags => '-device virtio-rng-pci -kernel ${config.system.build.ipxe}/ipxe.lkrn -m 768 -net nic,model=e1000 -net user,tftp=${config.system.build.ftpdir}/' });
      $machine->start;
      $machine->sleep(1);
      $machine->screenshot("test");
      $machine->shutdown;
    '';
  };
  normalBoot = makeTest {
    name = "normal-boot";
    nodes = {};
    testScript = '' 
      my $machine = createMachine({ qemuFlags => '-device virtio-rng-pci -kernel ${pkgs.linux}/bzImage -initrd ${config.system.build.initialRamdisk}/initrd -append "console=tty0 console=ttyS0 ${toString config.boot.kernelParams}" -drive index=0,id=drive1,file=${config.system.build.squashfs},readonly,media=cdrom,format=raw,if=virtio'});
      $machine->start;
      $machine->sleep(1);
      $machine->screenshot("test");
      $machine->shutdown;
    '';
  };
}
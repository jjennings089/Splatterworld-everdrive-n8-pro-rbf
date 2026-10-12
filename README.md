# Mapper 210 (Namco 175) for EverDrive N8 Pro

A custom mapper for the English Splatterworld patch (512K PRG). The N8 Pro's own mapper 210
is believed to keep only 5 bits of each PRG bank number, which is enough for any 256K game.
This patch needs all 6 bits.

- `src/map_210.sv` – the mapper
- `src/map_hub.sv` – routes mapper number 210 to it
- `build.sh` – fetches Krikzz's framework at a pinned commit, generates the Quartus project, builds

## Build

Needs an x86_64 Linux machine with Quartus Prime Lite (20.1.1 is what Krikzz last used) and its
Cyclone IV device support installed.

```bash
fpga/build.sh
```

Output: `fpga/out/splatterworld.rbf`

## Install

Requires N8 Pro OS v2.15 or newer. Copy the `.rbf` into the same SD card folder as the patched ROM.
If that folder holds more than one `.rbf`, rename it to match the ROM's file name.

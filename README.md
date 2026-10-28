# Splatterworld for EverDrive N8 Pro

## Download
Release v1


<a href="https://github.com/jjennings089/Splatterworld-everdrive-n8-pro-rbf/releases/download/v1.0.0/splatterworld.rbf">Splatterworld.rbf</a>


## Install

Requires N8 Pro OS v2.15 or newer. 

Copy the `splatterworld.rbf` into the same SD card folder as the game.
If that folder holds more than one `.rbf` file, rename it to match the game's file name.

## Mapper 210 (Namco 175) 

This is a custom mapper for Splatterworld; both the original Japanese and the English translation patch. The N8 Pro's own mapper: 
the game writes bank numbers with bit 5 set and relies on all 6 bits reaching the ROM.

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


## Credits
Thank you to **Krikzz** for building a great product and releasing code for users to build on.

EverDrive N8 Pro Dev Sources: https://github.com/krikzz/edn8-pro-pub 

Krikzz Products: https://krikzz.com/

Thank you to the **unknown person** who shared Splatterworld to the world; and all the **game devs** who worked on the game.

Thank you to **Aeon Genesis** for the English translation and notes on why it didn't work with the EverDrive https://aeongenesis.net/projects/splatterworld

Thank you to **West Mansion** for all things Splatterhouse related: https://splatterhouse.kontek.net

# blink

Blinks the LED on PA5 of an STM32F401 eval board using only Zig.

## Requirements

- Zig 0.16.0
- `stlink` (`sudo dnf install stlink` on Fedora)

## Build

```sh
zig build
```

Output: `zig-out/bin/blink.bin`

## Flash

```sh
st-flash write zig-out/bin/blink.bin 0x08000000
```

To flash without `sudo`, reload udev rules after installing stlink, then re-plug the board:

```sh
sudo udevadm control --reload-rules && sudo udevadm trigger
```

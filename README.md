# ESP32 + QEMU + Docker + GDB

This project includes a Dockerfile that extends the dockerized version of the esp-idf toolchain. 
It builds the ESP32-specific version of the QEMU emulator inside a docker container.
You can use this docker container to use QEMU to run your app in an emulator, and debug!
Also supports openethernet for virtual network communications.

This is some pretty advanced stuff, be prepared to spend a bit of time dialing in the config, and the instructions here are probably not perfect. YMMV

Based on instructions found at: https://github.com/espressif/qemu/wiki

# Setup
HIGHLY RECOMMEND always doing this under linux. If on windows, use WSL2 and do it on the native FS (windows shared fs into WSL is crazy slow)

Login to github container registry if needed (only needed if using a private fork of this repo)
```bash
# generate a personal access token and use it as your password: https://github.com/settings/tokens
docker login ghcr.io
```

In your esp32 project directory pull this docker container
```bash
# modify tag as needed
docker pull ghcr.io/unit-e/esp-idf-qemu:release-v4.4
```

Use this command to enter the container and run commands. use this for everything below.
Your code will show up as a volume in the container located at /project
```bash
# run this in linux host OS (either native linux or WSL2 running on top of windows)
docker run --rm -it --name esp-idf-qemu -v $PWD:/project -w /project ghcr.io/unit-e/esp-idf-qemu:release-v4.4 /bin/bash -c "bash"
```

# Build
```bash
# 1. in the container, build
idf.py build

# 2. generate a merged binary file
(cd build; esptool.py --chip esp32 merge_bin --fill-flash-size 4MB -o flash_image.bin @flash_args)
```

# Run your esp32 app in QEMU
```bash

# on terminal 1: run your app
# run from bash inside the docker container, like above.
# you should see your serial console output and be able to interact with it here
qemu-system-xtensa -nographic -machine esp32 -drive file=build/flash_image.bin,if=mtd,format=raw
```

# press CTRL+A and then one of the following to interact with QEMU:
ctrl+A then H - show help
ctrl+A then X - exit
https://www.qemu.org/docs/master/system/mux-chardev.html

# Debug a running app with GDB

Add a new config file to your top-level project dir called 'gdbinit', here's a sample:
```
target remote :1234
set remote hardware-watchpoint-limit 2
mon reset halt
flushregs
thb app_main
```

```bash

# like above, start the esp32 app, but this time:
# use gdb mode (-s) and halted at startup by default (-S)
qemu-system-xtensa -nographic -s -S -machine esp32 -drive file=build/flash_image.bin,if=mtd,format=raw

# while that's still running, open a new terminal and type this (via docker exec which will run this command in an existing docker already running container)
docker exec -it esp-idf-qemu /opt/esp/entrypoint.sh xtensa-esp32-elf-gdb build/YOUR_IMAGE_NAME.elf -x gdbinitl
```

# Tips:
- in GDB, press 'c' to begin execution of the app.
- to exit QEMU, press ```CTRL+A, X``` while it's running

GDB listens on port 1234, you should be able to use other debuggers (graphical, like CLion) to connect and debug the code using 'remote GDB' configs.

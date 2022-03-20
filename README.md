# ESP32 + QEMU + Docker + GDB

This project includes a Dockerfile that extends the dockerized version of the esp-idf toolchain. 
It builds the ESP32-specific version of the QEMU emulator inside a docker container.
You can use this docker container to use QEMU to run your app in an emulator, and debug!
Also supports openethernet for virtual network communications.

This is some pretty advanced stuff, be prepared to spend a bit of time dialing in the config, and the instructions here are probably not perfect. YMMV

Based on instructions found at: https://github.com/espressif/qemu/wiki

# Setup
HIGHLY RECOMMEND always doing this under linux. If on windows, use WSL2 and do it on the native FS (windows shared fs into WSL is crazy slow)
In your esp32 project directory pull this docker container
```bash
docker pull ghcr.io/unit-e/esp-idf-qemu  # add tag if needed
```

Use this command to enter the container and run commands. use this for everything below.
Your code will show up as a volume in the container located at /project
```bash
docker run --rm -it --name esp-idf-qemu -v $pwd:/project -w /project ghcr.io/unit-e/esp-idf-qemu:release-v4.3 /bin/bash -c "bash"
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
qemu-system-xtensa -nographic -s -S -machine esp32 -drive file=build/flash_image.bin,if=mtd,format=raw
```

# Debug a running app with GDB

Add a new config file to your top-level project dir called 'gdbinit', here's a sample:
```
target remote :1234
set remote hardware-watchpoint-limit 2
mon reset halt
flushregs
thb app_main
```

After starting the app above, on a new terminal run this:
Do this from your HOST OS (not windows)
'docker exec' is needed here because qemu must already be running by this point and it needs to connect to it
```bash
docker exec -it esp-idf-qemu /opt/esp/entrypoint.sh xtensa-esp32-elf-gdb build/YOUR_IMAGE_NAME.elf -x gdbinit
```

# Tips:
- in GDB, press 'c' to begin execution of the app.
- to exit QEMU, press ```CTRL+A, X``` while it's running

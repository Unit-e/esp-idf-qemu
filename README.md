# create compatible firmware file for qemu

generally follow stuff at: https://github.com/espressif/qemu/wiki

```bash
idf.py build
(cd build; esptool.py --chip esp32 merge_bin --fill-flash-size 4MB -o flash_image.bin @flash_args)
```

# start docker container

```bash

# on terminal 1:
.\docker-run.ps1 "qemu-system-xtensa -nographic -s -S -machine esp32 -drive file=build/flash_image.bin,if=mtd,format=raw"

# on terminal 2:
docker exec  -it docker-esp-idf /opt/esp/entrypoint.sh xtensa-esp32-elf-gdb build/rfpay.elf -x gdbinit
```

press 'c' to begin execution

press ```CTRL+A, X``` to exit qemu while it's running
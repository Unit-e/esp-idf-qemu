# create compatible firmware file for qemu

generally follow stuff at: https://github.com/espressif/qemu/wiki

```bash
idf.py build
(cd build; esptool.py --chip esp32 merge_bin --fill-flash-size 4MB -o flash_image.bin @flash_args)
```

# start docker container

```bash
docker run .. stuff ..
qemu-system-xtensa -nographic -machine esp32 -drive file=build/flash_image.bin,if=mtd,format=raw
```

press ```CTRL+A, X``` to exit qemu while it's running
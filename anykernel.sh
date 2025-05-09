### AnyKernel3 Ramdisk Mod Script
## KernelSU with SUSFS By Numbersf
## osm0sis @ xda-developers

### AnyKernel setup
# global properties
properties() { '
kernel.string=SukiSUUltra by KernelSU Developers and other people | Built by OdyMarGamer
do.devicecheck=0
do.modules=0
do.systemless=0
do.cleanup=1
do.cleanuponabort=1
device.name1=
device.name2=
device.name3=
device.name4=
device.name5=
supported.versions=
supported.patchlevels=
supported.vendorpatchlevels=
'; } # end properties

### AnyKernel install
## boot shell variables
block=boot
is_slot_device=auto
ramdisk_compression=auto
patch_vbmeta_flag=auto
no_magisk_check=1

# import functions/variables and setup patching - see for reference (DO NOT REMOVE)
. tools/ak3-core.sh

kernel_version=$(cat /proc/version | awk -F '-' '{print $1}' | awk '{print $3}')
case $kernel_version in
    5.1*) ksu_supported=true ;;
    6.1*) ksu_supported=true ;;
    *) ksu_supported=false ;;
esac

ui_print "  -> ksu_supported: $ksu_supported"
$ksu_supported || abort "  -> Non-GKI device, abort."

# Determine the root method
if [ -d /data/adb/magisk ] || [ -f /sbin/.magisk ]; then
    ui_print "Magisk detected, current root method is Magisk. Flashing the KSU kernel in this case may brick your device, do you want to continue?"
    ui_print "Please select an action:"
    ui_print "Volume up key: No"
    ui_print "Volume down button: Yes"
    key_click=""
    while [ "$key_click" = "" ]; do
        key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
        sleep 0.2
    done
    case "$key_click" in
        "KEY_VOLUMEUP") 
            ui_print "You have chosen to exit the installation"
            ui_print "Exiting…"
            exit 0
            ;;
        "KEY_VOLUMEDOWN")
            ui_print "You have chosen to continue the installation"
            ;;
        *)
            ui_print "Unknown key, exit script"
            exit 1
            ;;
    esac
fi

ui_print "Starting-Installation-off-the-kernel..."
ui_print "Powered by GitHub@OdymarGamer"
if [ -L "/dev/block/bootdevice/by-name/init_boot_a" ] || [ -L "/dev/block/by-name/init_boot_a" ]; then
    split_boot
    flash_boot
else
    dump_boot
    write_boot
fi

# Prioritize module paths
if [ -f "$AKHOME/ksu_module_susfs_1.5.2+.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs_1.5.2+.zip"
    ui_print "  -> Installing SUSFS module from Release (1.5.2+)"
elif [ -f "$AKHOME/ksu_module_susfs.zip" ]; then
    MODULE_PATH="$AKHOME/ksu_module_susfs.zip"
    ui_print "  -> Installing SUSFS module from CI"
else
    ui_print "  -> No SUSFS module found!"
    exit 1
fi

KSUD_PATH="/data/adb/ksud"
ui_print "Install susfs4ksu module?Volume up: NO；Volume down: YES"

key_click=""
while [ "$key_click" = "" ]; do
    key_click=$(getevent -qlc 1 | awk '{ print $3 }' | grep 'KEY_VOLUME')
    sleep 0.2
done
case "$key_click" in
    "KEY_VOLUMEDOWN")
        if [ -f "$KSUD_PATH" ]; then
            ui_print "Installing SUSFS Module..."
            /data/adb/ksud module install "$MODULE_PATH"
            ui_print "Installation Complete"
        else
            ui_print "KSUD Not Found, skipping installation"
        fi
        ;;
    "KEY_VOLUMEUP")
        ui_print "Skipping SUSFS module installation"
        ;;
    *)
        ui_print "Unknown key input, skipping installation"
        ;;
esac

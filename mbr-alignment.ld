ENTRY(_boot)
OUTPUT_FORMAT("binary")

SECTIONS
{
    /* The BIOS loads the code from the disk to this location.
     * We must tell that to the linker so that it can properly
     * calculate the addresses of symbols we might jump to.
     */
    . = 0x7c00;
    .text :
    {
        pong.o
        /* The boot signature, the last two bytes of the 512 byte segment, this marks the MBR to be bootable */
        . = 0x1fe;
        SHORT(0xaa55)
    }
}

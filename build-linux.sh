if test "`whoami`" != "root" ; then
	echo "You must be logged in as root to build (for loopback mounting)"
	echo "Enter 'su' or 'sudo bash' to switch to root"
	exit
fi


if [ ! -e image_disk/VegaOS.flp ]
then
	echo ">>> Creating new VegaOS floppy image..."
	mkdosfs -C image_disk/VegaOS.flp 1440 || exit
fi


echo ">>> Assembling bootloader..."

nasm -O0 -w+orphan-labels -f bin -o source/bootloader/bootloader.bin source/bootloader/bootloader.asm || exit


echo ">>> Assembling MikeOS kernel..."

cd source
nasm -O0 -w+orphan-labels -f bin -o kernel.bin kernel.asm || exit
cd ..


echo ">>> Assembling programs..."





echo ">>> Adding bootloader to floppy image..."

dd status=noxfer conv=notrunc if=source/bootloader/bootloader.bin of=image_disk/VegaOS.flp || exit


echo ">>> Copying MikeOS kernel and programs..."

rm -rf tmp-loop

mkdir tmp-loop && mount -o loop -t vfat image_disk/VegaOS.flp tmp-loop && cp source/kernel.bin tmp-loop/



sleep 0.2

echo ">>> Unmounting loopback floppy..."

umount tmp-loop || exit

rm -rf tmp-loop


echo ">>> Creating CD-ROM ISO image..."

rm -f image_disk/VegaOS.iso
mkisofs -quiet -V 'MIKEOS' -input-charset iso8859-1 -o image_disk/VegaOS.iso -b VegaOS.flp image_disk/ || exit

echo '>>> Success!'

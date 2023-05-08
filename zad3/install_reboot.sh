cd /usr/src/minix/servers/pm
make
make install
cd ../../../lib/libc
make 
make install
cd /usr/src/minix/fs/procfs
make 
make install
cd /usr/src/minix/drivers/storage/ramdisk
make 
make install
cd /usr/src/minix/drivers/storage/memory
make 
make install
cd /usr/src/releasetools
make do-hdboot
/sbin/reboot	

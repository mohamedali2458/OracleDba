Emptying the buffers cache

#as root user
free && sync && echo 3 > /proc/sys/vm/drop_caches && free


You can signal the Linux Kernel to drop various aspects of cached items by changing the numeric argument to the above command.

To free pagecache:

# echo 1 > /proc/sys/vm/drop_caches
To free dentries and inodes:

# echo 2 > /proc/sys/vm/drop_caches
To free pagecache, dentries and inodes:

# echo 3 > /proc/sys/vm/drop_caches



#as sudo
$ sudo sh -c 'echo 1 >/proc/sys/vm/drop_caches'
$ sudo sh -c 'echo 2 >/proc/sys/vm/drop_caches'
$ sudo sh -c 'echo 3 >/proc/sys/vm/drop_caches'


Swap
If you want to clear out your swap you can use the following commands.

$ free

Then use this command to disable swap:

$ swapoff -a

You can confirm that it's now empty:

$ free

And to re-enable it:

$ swapon -a

And now reconfirm with free:

$ free


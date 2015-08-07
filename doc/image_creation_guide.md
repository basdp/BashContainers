# Image creation guide

## Raspbian
```
wget http://downloads.raspberrypi.org/raspbian_latest
unzip raspbian_latest
fdisk -l 2015-05-05-raspbian-wheezy.img
```
Notice the unit size: `Units: sectors of 1 * 512 = 512 bytes`. Most likely this is 512 bytes, but it might be different.
Multiply the `Start` offset of the main partition by the unit size to get the offset in bytes. Use this offset to mount the image:
```
mount -v -o offset=62914560 -t ext4 2015-05-05-raspbian-wheezy.img /mnt/payload
cd /mnt
tar -cpzf payload.tar.gz payload/
mkdir raspbian-latest
mv payload.tar.gz raspbian-latest
touch raspbian-latest/thinderfile
cat > raspbian-latest/meta <<EOL
name=raspbian
version=2015-05-05
creationdate=$(date +"%Y-%m-%d %H:%M:%S")
EOL
```
The Thinder image of a clean Raspbian install is at /mnt/raspbian-latest

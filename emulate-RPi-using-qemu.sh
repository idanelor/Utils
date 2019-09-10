#!/bin/sh

#  MacOS Mojave

brew install qemu
brew install wget
brew install node
npm -g install webtorrent-cli
export QEMU=$(which qemu-system-arm)
export TMP_DIR=~/tmp/qemu-rpi
export RPI_KERNEL=${TMP_DIR}/kernel-qemu-4.4.34-jessie
export RPI_FS=${TMP_DIR}/2017-04-10-raspbian-jessie.img
export PTB_FILE=${TMP_DIR}/versatile-pb.dtb
export IMAGE_FILE=2017-04-10-raspbian-jessie.zip
export IMAGE_FILE_TORRENT=${IMAGE_FILE}.torrent
export IMAGE=http://downloads.raspberrypi.org/raspbian/images/raspbian-2017-04-10/${IMAGE_FILE_TORRENT}


while [ "$1" != "" ]; do
    case $1 in
        -o | --override )           
			shift
            rm -rf TMP_DIR
            ;;
        * )                     usage
                                exit 1
    esac
    shift
done

mkdir -p $TMP_DIR; cd $TMP_DIR

if ! [ -f "${RPI_FS}" ]
then
	wget -c https://github.com/dhruvvyas90/qemu-rpi-kernel/blob/master/kernel-qemu-4.4.34-jessie?raw=true -O ${RPI_KERNEL}

	wget -c https://github.com/dhruvvyas90/qemu-rpi-kernel/raw/master/versatile-pb.dtb -O ${PTB_FILE}

	wget -c $IMAGE

	webtorrent download $IMAGE_FILE_TORRENT
	unzip -n $IMAGE_FILE
fi

$QEMU -kernel ${RPI_KERNEL} \
	-cpu arm1176 -m 256 \
	-M versatilepb \
	-serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
	-drive "file=${RPI_FS},index=0,media=disk,format=raw" \
	-net user,hostfwd=tcp::5022-:22 -net nic -no-reboot -D  ${TMP_DIR}/log


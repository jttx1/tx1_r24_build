
################################################################################
##
## To support:
##  1. Full flash
##  3. Update kernel Image & dtb
##
################################################################################

function flash()
{
    pushd ${L4TOUT} &> /dev/null
    sudo ./flash.sh  $@ $TARGET_DEV mmcblk0p1;
    popd &> /dev/null
}

function kernel_dtb_update()
{
	if [ -z "$TX1_USER" -o -z "$TX1_PWD" -o -z "$TX1_IP" ]
	then
		echo "${red}please specify the user@ip and password of TX1 device${normal}"; echo
		return 1
	fi

	local DTB_FILE=`cat $L4TOUT/${TARGET_DEV}.conf | grep DTB_FILE | cut -d "=" -f 2`

	echo "sshpass -p \"$TX1_PWD\" scp $KERNEL_OUT/arch/arm64/boot/Image $TX1_USER@$TX1_IP:~/"
	sshpass -p "$TX1_PWD" scp $KERNEL_OUT/arch/arm64/boot/Image $TX1_USER@$TX1_IP:~/
	echo "sshpass -p \"$TX1_PWD\" scp $KERNEL_OUT/arch/arm64/boot/dts/$DTB_FILE $TX1_USER@$TX1_IP:~/"
	sshpass -p "$TX1_PWD" scp $KERNEL_OUT/arch/arm64/boot/dts/$DTB_FILE $TX1_USER@$TX1_IP:~/
	echo
	echo "${red}please login TX1 device, and copy Image and dtb file into /boot/ folder${normal}"
	echo
	sshpass -p "$TX1_PWD" ssh $TX1_USER@$TX1_IP
}

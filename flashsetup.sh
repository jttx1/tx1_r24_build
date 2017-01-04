
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
	local lmd5
	local rmd5

	if [ -z "$TX1_USER" -o -z "$TX1_PWD" -o -z "$TX1_IP" ]
	then
		echo "${red}please specify the user@ip and password of TX1 device${normal}"; echo
		return 1
	fi

	local DTB_FILE=`cat $L4TOUT/${TARGET_DEV}.conf | grep DTB_FILE | cut -d "=" -f 2`

	## Image
	echo "sshpass -p \"$TX1_PWD\" scp $KERNEL_OUT/arch/arm64/boot/Image $TX1_USER@$TX1_IP:~/"
	sshpass -p "$TX1_PWD" scp $KERNEL_OUT/arch/arm64/boot/Image $TX1_USER@$TX1_IP:~/
	echo "sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP \"sudo cp ~/Image /boot/\""
	sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP "sudo cp ~/Image /boot/"
	lmd5=`md5sum $KERNEL_OUT/arch/arm64/boot/Image | cut -d " " -f 1`
	rmd5=`sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP "md5sum /boot/Image" | cut -d " " -f 1`
	if [ "$lmd5" = "$rmd5" ]; then
		echo "Image update successsfully"
	else
		echo "Image update failed"
	fi

	## DTB
	echo "sshpass -p \"$TX1_PWD\" scp $KERNEL_OUT/arch/arm64/boot/dts/$DTB_FILE $TX1_USER@$TX1_IP:~/"
	sshpass -p "$TX1_PWD" scp $KERNEL_OUT/arch/arm64/boot/dts/$DTB_FILE $TX1_USER@$TX1_IP:~/
	echo "sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP \"sudo cp ~/$DTB_FILE /boot/\""
	sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP "sudo cp ~/$DTB_FILE /boot/"
	lmd5=`md5sum $KERNEL_OUT/arch/arm64/boot/dts/$DTB_FILE | cut -d " " -f 1`
	rmd5=`sshpass -p "$TX1_PWD" ssh -t -l $TX1_USER $TX1_IP "md5sum /boot/$DTB_FILE" | cut -d " " -f 1`
	if [ "$lmd5" = "$rmd5" ]; then
		echo "Image update successsfully"
	else
		echo "Image update failed"
	fi
	echo
}

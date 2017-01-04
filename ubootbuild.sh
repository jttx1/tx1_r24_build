
################################################################################
##
## To support:
##  1. ubootbuild: uboot build
##
################################################################################

mkdir -p $UBOUTOUT_2180
mkdir -p $UBOUTOUT_0000

function _prepare_dirs()
{
	mkdir -p $UBOUTOUT_2180
	mkdir -p $UBOUTOUT_0000
}

function _ubootinstall()
{
	_prepare_dirs

	local UBOUTOUT_SRC

	echo; echo -n "uboot install..."
	if [ "$TARGET_DEV" = "p2371-0000" ]
	then
		local UBOUTOUT_SRC=$UBOUTOUT_0000
		local UBOUTOUT_DST=$L4TOUT/bootloader/t210ref/p2371-0000/
	else
		local UBOUTOUT_SRC=$UBOUTOUT_2180
		local UBOUTOUT_DST=$L4TOUT/bootloader/t210ref/p2371-2180/
	fi

	cp $UBOUTOUT_SRC/u-boot $UBOUTOUT_DST
	cp $UBOUTOUT_SRC/u-boot.bin $UBOUTOUT_DST
	cp $UBOUTOUT_SRC/u-boot.dtb $UBOUTOUT_DST
	cp $UBOUTOUT_SRC/u-boot-dtb.bin $UBOUTOUT_DST
	echo "Done"
}

function _ubootbuildimage()
{
	_prepare_dirs
	_getnumcpus

	local MAKE_OPTIONS="ARCH=arm CROSS_COMPILE=$AARCH64_TOOLCHAIN"

	echo; echo "start uboot build..."
	if [ "$TARGET_DEV" = "p2371-0000" ]
	then
		#echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000 disclean"
		#make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000 distclean
		echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000 $TARGET_UBOUT_0000_DEFCONFIG"
		make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000 $TARGET_UBOUT_0000_DEFCONFIG
		echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000"
		make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_0000
	else
		#echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180 disclean"
		#make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180 distclean
		echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180 $TARGET_UBOUT_2180_DEFCONFIG"
		make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180 $TARGET_UBOUT_2180_DEFCONFIG
		echo "make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180"
		make -C $UBOOT_PATH $MAKE_OPTIONS O=$UBOUTOUT_2180
	fi
}

function ubuild()
{
	_prepare_dirs

	_ubootbuildimage && _ubootinstall

	echo; echo "Done";
}

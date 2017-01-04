
################################################################################
##
## To support:
##  1. bspsetup: toolchain, kernel and u-boot source setup
##  2. l4tout_setup: setup Linux_for_Tegra
##
################################################################################

function _later_check()
{
	[ -d $L4TOUT ]|| (echo "${red} _early_check failed${normal}" && return 1)
	[ -f ${AARCH64_TOOLCHAIN}gcc ] || (echo "${red} ${AARCH64_TOOLCHAIN}gcc check failed${normal}" && return 1)
	[ -f ${ARMHF_TOOLCHAIN}gcc ] || (echo "${red} ${ARMHF_TOOLCHAIN}gcc check failed${normal}" && return 1)
	[ -d $UBOOT_PATH ] || (echo "${red} $UBOOT_PATH check failed${normal}" && return 1)
	[ -d $KERNEL_PATH ] || (echo "$KERNEL_PATH check failed${normal}" && return 1)
}

function _toolchain_setup()
{
	# aarch64: for kernel and app
	if [ ! -f ${AARCH64_TOOLCHAIN}gcc ]
	then
		pushd $TOP/prebuilts/gcc/aarch64 &> /dev/null
		wget $AARCH64_TOOLCHAIN_LINK -O gcc-4.8.5-aarch64.tgz
		tar xpf gcc-4.8.5-aarch64.tgz
		popd &> /dev/null
	fi

	# armhf: for kernel CROSS32CC
	if [ ! -f ${ARMHF_TOOLCHAIN}gcc ]
	then
		pushd $TOP/prebuilts/gcc/armhf &> /dev/null
		wget $ARMHF_TOOLCHAIN_LINK -O gcc-4.8.5-armhf.tgz
		tar xpf gcc-4.8.5-armhf.tgz
		popd &> /dev/null
	fi
}

function _sources_setup()
{
	local SOURCE_PACKAGE=$TOP/jetpack_download/sources.tbz2
	local SOURCE_UNTAR_DIR=$TOP/.tmp

	cd $TOP

	# Source download
	if [ ! -f $SOURCE_PACKAGE ]
	then
		echo; echo "download source code..."
		mkdir -p $TOP/jetpack_download
		pushd $TOP/jetpack_download &> /dev/null
		wget $SOURCES_LINK -O sources.tbz2
		popd &> /dev/null
	fi

	# kernel source
	mkdir -p $TOP/.tmp
	if [ ! -d  $KERNEL_PATH ]
	then
		echo; echo "Setup kernel source code..."
		pushd $TOP/.tmp &> /dev/null; tar xpf $SOURCE_PACKAGE; popd &> /dev/null
		cd $TOP
		tar xpf $TOP/.tmp/sources/$KERNEL_SRC
	fi
	rm -rf $TOP/.tmp

	### u-boot source
	mkdir -p $TOP/.tmp
	if [ ! -d  $UBOOT_PATH ]
	then
		echo; echo "Setup u-boot source code..."
		pushd $TOP/.tmp &> /dev/null; tar xpf $SOURCE_PACKAGE; popd &> /dev/null
		cd $TOP
		tar xpf $TOP/.tmp/sources/$UBOOT_SRC
	fi
	rm -rf $TOP/.tmp
}

function mm_api_sdk_setup()
{
	if [ ! -d $MM_API_SDK_SRC ]
	then
		pushd $TOP &> /dev/null
		tar xpf $TOP/jetpack_download/Tegra_Multimedia_API_R24.2.1_aarch64.tbz2
		popd &> /dev/null
	fi

	pushd $TARGET_ROOTFS/usr/lib &> /dev/null
	sudo ln -sf $TEGRA_ARMABI/crt1.o crt1.o
	sudo ln -sf $TEGRA_ARMABI/crti.o crti.o
	sudo ln -sf $TEGRA_ARMABI/crtn.o crtn.o
	popd &> /dev/null
	pushd $TARGET_ROOTFS/usr/lib/$TEGRA_ARMABI &> /dev/null
	sudo ln -sf libv4l2.so.0 libv4l2.so
	sudo ln -sf tegra-egl/libEGL.so.1 libEGL.so
	sudo ln -sf tegra-egl/libGLESv2.so.2 libGLESv2.so
	sudo ln -sf tegra/libcuda.so.1.1 libcuda.so.1
	sudo ln -sf ../../../lib/aarch64-linux-gnu/libdl.so.2 libdl.so
	popd &> /dev/null
}

function l4tout_setup()
{
	mkdir -p $TOP/64_TX1

	echo -n "${yel}Are you sure to setup l4tout? [n/y] "
	read ANSWER
	if [ "$ANSWER"x != "y"x ]
	then
		return 0
	fi
	echo "${normal}"

	sudo rm -rf $TOP/64_TX1/Linux_for_Tegra_64_tx1

	mkdir -p $TOP/.tmp
	pushd $TOP/.tmp &> /dev/null
	echo "tar xpf $TOP/jetpack_download/Tegra210_Linux_${DEFAULT_TARGET_RELEASE}_aarch64.tbz2"
	tar xpf $TOP/jetpack_download/Tegra210_Linux_${DEFAULT_TARGET_RELEASE}_aarch64.tbz2
	mv Linux_for_Tegra $TOP/64_TX1/Linux_for_Tegra_64_tx1
	popd &> /dev/null
	rm -rf $TOP/.tmp

	echo "sudo tar xpf $TOP/jetpack_download/Tegra_Linux_Sample-Root-Filesystem_${DEFAULT_TARGET_RELEASE}_aarch64.tbz2"
	pushd $L4TOUT/rootfs &> /dev/null
	sudo tar xpf $TOP/jetpack_download/Tegra_Linux_Sample-Root-Filesystem_${DEFAULT_TARGET_RELEASE}_aarch64.tbz2
	popd &> /dev/null
	
	echo "sudo ./apply_binaries.sh"
	pushd $L4TOUT &> /dev/null
	sudo ./apply_binaries.sh
	popd &> /dev/null

	sync
}

function bspsetup()
{
	if [ ! -d $L4TOUT ]
	then
		echo "${red}Linux_for_Tegra is missing."
        echo "plaese run  \"${yel}l4tout_setup${red}\" to setup${normal}"
		return 1;
	fi

	## Toolochain
	mkdir -p $TOP/prebuilts
	mkdir -p $TOP/prebuilts/gcc
	mkdir -p $TOP/prebuilts/gcc/aarch64
	mkdir -p $TOP/prebuilts/gcc/armhf

	_toolchain_setup && _sources_setup && mm_api_sdk_setup
	
	_later_check || (echo "${red}_later_check failed, BSP setup failed!${normal}" && return 1)
		
	echo "${mag}BSP setup successfully!${normal}"; echo
}

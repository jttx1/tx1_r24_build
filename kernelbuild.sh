
################################################################################
##
## To support:
##  1. krebuild: kernel Image and dtb build
##  2. kmenuconfig & ksavedefconfig: kernel defconfig update
##
################################################################################


mkdir -p $KERNEL_OUT
mkdir -p $INSTALL_KERNEL_MODULES_PATH

function _prepare_dirs()
{
	mkdir -p $KERNEL_OUT
	mkdir -p $INSTALL_KERNEL_MODULES_PATH
}

function _getdefconfig()
{
	TARGET_KERNEL_CONFIG=tegra21_defconfig
}

function kmenuconfig()
{
	_prepare_dirs

	local MAKE_OPTIONS="ARCH=arm64 CROSS_COMPILE=$AARCH64_TOOLCHAIN O=$KERNEL_OUT"

    echo "make -C $KERNEL_PATH $MAKE_OPTIONS menuconfig"
    make -C $KERNEL_PATH $MAKE_OPTIONS menuconfig
}

function ksavedefconfig()
{
	local MAKE_OPTIONS="ARCH=arm64 CROSS_COMPILE=$AARCH64_TOOLCHAIN O=$KERNEL_OUT"

	echo "make -C $KERNEL_PATH $MAKE_OPTIONS savedefconfig"
	make -C $KERNEL_PATH $MAKE_OPTIONS savedefconfig
	cp $KERNEL_OUT/defconfig $KERNEL_PATH/arch/arm64/configs/$TARGET_KERNEL_CONFIG
}

function kinstall()
{
	_prepare_dirs

	echo; echo "kernell install..."
	cp $KERNEL_OUT/arch/arm64/boot/Image $L4TOUT/kernel/
    cp $KERNEL_OUT/arch/arm64/boot/dts/*.dtb $L4TOUT/kernel/dtb/
    pushd $INSTALL_KERNEL_MODULES_PATH &> /dev/null
    tar --owner root --group root -cjf kernel_supplements.tbz2 lib/modules
    popd &> /dev/null
    mv $INSTALL_KERNEL_MODULES_PATH/kernel_supplements.tbz2 $L4TOUT/kernel/
	echo "Done"; echo
}

function kbuildimage()
{
	_prepare_dirs
	_getnumcpus
	_getdefconfig

	local MAKE_OPTIONS="ARCH=arm64 CROSS_COMPILE=$AARCH64_TOOLCHAIN CROSS32CC=${ARMHF_TOOLCHAIN}gcc O=$KERNEL_OUT -j${NUMCPUS} V=0"

	echo; echo "start Image build..."
	echo "make -C $KERNEL_PATH $MAKE_OPTIONS $TARGET_KERNEL_CONFIG"
    make -C $KERNEL_PATH $MAKE_OPTIONS $TARGET_KERNEL_CONFIG
    echo "make -C $KERNEL_SRC_DIR $MAKE_OPTIONS Image dtbs"
    make -C $KERNEL_PATH $MAKE_OPTIONS Image
}

function kbuilddtb()
{
	_prepare_dirs
	_getnumcpus

	local MAKE_OPTIONS="ARCH=arm64 CROSS_COMPILE=$AARCH64_TOOLCHAIN CROSS32CC=${ARMHF_TOOLCHAIN}gcc O=$KERNEL_OUT -j${NUMCPUS} V=0"

	echo; echo "start dtbs build..."
	make -C $KERNEL_PATH $MAKE_OPTIONS dtbs
}

function kbuildmodule()
{
	_prepare_dirs
	_getnumcpus

	local MAKE_OPTIONS="ARCH=arm64 CROSS_COMPILE=$AARCH64_TOOLCHAIN CROSS32CC=${ARMHF_TOOLCHAIN}gcc O=$KERNEL_OUT -j${NUMCPUS} V=0"

	echo ; echo; echo "start modules build..."
    echo "make -C $KERNEL_SRC_DIR $MAKE_OPTIONS modules DESTDIR=$INSTALL_KERNEL_MODULES_PATH"
    make -C $KERNEL_PATH $MAKE_OPTIONS modules DESTDIR=$INSTALL_KERNEL_MODULES_PATH
    echo "make -C $KERNEL_SRC_DIR $MAKE_OPTIONS modules_install INSTALL_MOD_PATH=$INSTALL_KERNEL_MODULES_PATH"
    make -C $KERNEL_PATH $MAKE_OPTIONS modules_install INSTALL_MOD_PATH=$INSTALL_KERNEL_MODULES_PATH
}

function kbuild()
{
	_prepare_dirs

	kbuildimage && kbuilddtb && kbuildmodule && kinstall

	echo "Done"; echo
}


red=$'\e[31m'
grn=$'\e[32m'
yel=$'\e[33m'
blu=$'\e[34m'
mag=$'\e[35m'
cyn=$'\e[36m'
normal=$'\e[0m'

export TOP=$PWD

TARGET_DEV_ARRAY=(p2371-2180-devkit p2371-2180-devkit-24x7 p2371-2180 p2371-0000)
TARGET_RELEASE_ARRAY=(R24.2 R24.2.1)

DEFAULT_TARGET_DEV=p2371-2180-devkit
DEFAULT_TARGET_RELEASE=R24.2.1

source $TOP/build/.config &> /dev/null

function choosedevice()
{
	if [ ! -z "$TARGET_DEV" ]
	then
		return 0
	fi

	local index=0
    local v
    for v in ${TARGET_DEV_ARRAY[@]}
    do
        echo "     $index. $v"
        index=$(($index+1))
    done

    local ANSWER
    while [ -z "$TARGET_DEV" ]
    do
        echo -n "Which device would you choose? [$DEFAULT_TARGET_DEV] "
        read ANSWER

        if [ -z "$ANSWER" ] ; then
            export TARGET_DEV=$DEFAULT_TARGET_DEV
        else
			if [ $ANSWER -lt ${#TARGET_DEV_ARRAY[@]} ]
			then
                export TARGET_DEV=${TARGET_DEV_ARRAY[$ANSWER]}
            else
                echo "** Not a valid device option: $ANSWER"
            fi
        fi
    done

}

function chooserelease()
{
    if [ ! -z "$TARGET_RELEASE" ]
    then
        return 0
    fi

    local index=0
    local v
    for v in ${TARGET_RELEASE_ARRAY[@]}
    do
        echo "     $index. $v"
        index=$(($index+1))
    done

    local ANSWER
    while [ -z "$TARGET_RELEASE" ]
    do
        echo -n "Which release would you choose? [$DEFAULT_TARGET_RELEASE] "
        read ANSWER

        if [ -z "$ANSWER" ] ; then
            export TARGET_RELEASE=$DEFAULT_TARGET_RELEASE
        else
            if [ $ANSWER -lt ${#TARGET_RELEASE_ARRAY[@]} ]
            then
                export TARGET_RELEASE=${TARGET_RELEASE_ARRAY[$ANSWER]}
            else
                echo "** Not a valid release option: $ANSWER"
            fi
        fi
    done
}

function set_tx1_user()
{
    if [ ! -z "$TX1_USER" ]
    then
        return 0
    fi

    local ANSWER
    while [ -z "$TX1_USER" ]
    do
        echo -n "Login user of TX1 device? [ubuntu] "
        read ANSWER

        if [ -z "$ANSWER" ] ; then
            export TX1_USER=ubuntu
        else
            export TX1_USER=$ANSWER
        fi
    done
}

function set_tx1_pwd()
{
    if [ ! -z "$TX1_PWD" ]
    then
        return 0
    fi

    local ANSWER
    while [ -z "$TX1_PWD" ]
    do
        echo -n "Login password of TX1 device? [ubuntu] "
        read ANSWER


        if [ -z "$ANSWER" ] ; then
            export TX1_PWD=ubuntu
        else
            export TX1_PWD=$ANSWER
        fi
    done
}

function set_tx1_ip()
{
    if [ ! -z "$TX1_IP" ]
    then
        return 0
    fi

    local ANSWER
    while [ -z "$TX1_IP" ]
    do
        echo -n "IP address of TX1 device? "
        read ANSWER

        if [ -z "$ANSWER" ] ; then
			break;
        else
            export TX1_IP=$ANSWER
			break;
        fi
    done
}

function _getnumcpus()
{
	NUMCPUS=2
    NUMCPUS=`cat /proc/cpuinfo | grep processor | wc -l`
}

choosedevice
chooserelease
set_tx1_user
set_tx1_pwd
set_tx1_ip
echo
echo "${TARGET_DEV_ARRAY[@]}" | grep -w "$TARGET_DEV" 2>&1 >/dev/null || (echo "invalid target device" && return 1)
echo "${TARGET_RELEASE_ARRAY[@]}" | grep -w "$TARGET_RELEASE" 2>&1 >/dev/null || (echo "invalid target release" && return 1)

echo "${yel}Please confirm below configuration:${normal}"
echo "${grn}"
echo "TARGET_DEV                : $TARGET_DEV"
echo "TARGET_RELEASE            : $TARGET_RELEASE"
echo "TX1 device login user     : $TX1_USER"
echo "TX1 device login password : $TX1_PWD"
echo "TX1 device IP             : $TX1_IP"
echo
echo -n "${yel}Are these right? [n/y] "
read ANSWER
if [ "$ANSWER"x = "n"x ]
then
	echo "rm -f $TOP/build/.config"
    rm -f $TOP/build/.config
	export TARGET_DEV=
	export TARGET_RELEASE=
	export TX1_USER=
	export TX1_PWD=
	export TX1_IP=
	echo "please re-configure with $ . build/envsetup.sh"
	echo "${normal}"
	return 1
fi
echo "${normal}"

## re-write build/.config
echo "TARGET_DEV=$TARGET_DEV" >$TOP/build/.config
echo "TARGET_RELEASE=$TARGET_RELEASE" >>$TOP/build/.config
echo "TX1_USER=$TX1_USER" >>$TOP/build/.config
echo "TX1_PWD=$TX1_PWD" >>$TOP/build/.config
echo "TX1_IP=$TX1_IP" >>$TOP/build/.config

## Download Links
AARCH64_TOOLCHAIN_LINK=https://developer.nvidia.com/embedded/dlc/l4t-gcc-toolchain-64-bit-24-2-1
ARMHF_TOOLCHAIN_LINK=https://developer.nvidia.com/embedded/dlc/l4t-gcc-toolchain-32-bit-24-2-1
if [ "$TARGET_RELEASE" = "R24.2" ]
then
SOURCES_LINK=https://developer.nvidia.com/embedded/dlc/l4t-24-2-sources
else
SOURCES_LINK=https://developer.nvidia.com/embedded/dlc/l4t-sources-24-2-1
fi

# Toolchain
AARCH64_TOOLCHAIN=$TOP/prebuilts/gcc/aarch64/install/bin/aarch64-unknown-linux-gnu-
ARMHF_TOOLCHAIN=$TOP/prebuilts/gcc/armhf/install/bin/arm-unknown-linux-gnueabi-

# U-Boot
UBOOT_SRC=u-boot_src.tbz2
UBOOT_PATH=$TOP/u-boot
UBOUTOUT_2180=$TOP/out/uboot-p2371-2180
UBOUTOUT_0000=$TOP/out/uboot-p2371-0000
TARGET_UBOUT_2180_DEFCONFIG=p2371-2180_defconfig
TARGET_UBOUT_0000_DEFCONFIG=p2371-2180_defconfig

# Kernel
KERNEL_SRC=kernel_src.tbz2
KERNEL_PATH=$TOP/kernel
KERNEL_OUT=$TOP/out/KERNEL
INSTALL_KERNEL_MODULES_PATH=$TOP/out/MODULES
INSTALL_KHDR_PATH=$KERNELOUT/

# OUT
L4TOUT=$TOP/64_TX1/Linux_for_Tegra_64_tx1

# MM API SDK
MM_API_SDK_SRC=$TOP/tegra_multimedia_api
export CROSS_COMPILE=$AARCH64_TOOLCHAIN
export TARGET_ROOTFS=$L4TOUT/rootfs/
export TEGRA_ARMABI=aarch64-linux-gnu
export PATH=$PATH:`dirname $AARCH64_TOOLCHAIN`

source $TOP/build/bspsetup.sh
source $TOP/build/kernelbuild.sh
source $TOP/build/ubootbuild.sh
source $TOP/build/flashsetup.sh

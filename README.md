L4T TX1 R24 Release Build Assistant Scripts
===========================================

Background
----------
  After you download lots of files through JetPack-L4T-x.x.x-linux-x64.run, you
still need to download toolchains, kernel & u-boot source codes and other app
(e.g. MM API SDK) stuffs to setup the development environment on your Linux Host
PC, in addition, you need also collect some handy commands to build the code,
flash the images, etc.
  So, these scripts are to help developer to setup the develop environment and
provide the handy commands.


Introduction
------------
	1. Put this "build" folder under the top folder downloaded by Jetpack
    2. The relevant files for this scripts and their layout.

	   Note: In below layout, 64_TX1, jetpack_download are downloaded by Jetpack.
	   And, sources.tbz2 under jetpack_download, kernel, u-boot, prebuilts are
	   setup by command "bspsetp".


       $TOP
         ├── 64_TX1                  ----> All images are put under this for flash
         │   └── Linux_for_Tegra_64_tx1
         │       ├── apply_binaries.sh
         │       ├── bootloader
         │          ....
         ├── jetpack_download
         │   ├── ....
         │   ├── sources.tbz2      ---> source code of kernel, u-boot and app
         │   ├── Tegra210_Linux_R24.2.1_aarch64.tbz2
         │   ├── Tegra_Linux_Sample-Root-Filesystem_R24.2.1_aarch64.tbz2
         │   └── Tegra_Multimedia_API_R24.2.1_aarch64.tbz2
         ├── JetPack-L4T-2.3.1-linux-x64.run
         ├── kernel                --> kernel source code
		 ├── u-boot                --> u-boot source code
		 ├── tegra_multimedia_api  --> MM API SDK
		 │	 ├── argus
		 │   ├── CROSS_PLATFORM_SUPPORT
         │
		 ├── prebuilts
		 │   └── gcc
         │		 ├── aarch64       --> aarch64 toolchain binary
         │    	 └── armhf         --> armhf (32bit) toolchain binary
         ├── build                 --> This Build Assistant Scripts
		 │   ├── bspsetup.sh
		 │   ├── envsetup.sh
		 │   ├── flashsetup.sh
		 │   ├── kernelbuild.sh
		 │   ├── README
		 │   └── ubootbuild.sh
		 ├── out                    --> kernel & uboot build output.
		 │   ├── KERNEL                 their images will be put into 
		 │   ├── MODULES                "Linux_for_Tegra_64_tx1" for flash.
		 │   ├── uboot-p2371-0000
		 │   └── uboot-p2371-2180

    3. Commands
	   3.1 $ . build/envsetup.sh
             > This command must be executed under the TOP folder downloaded by Jetpack
		     > This command is to setup some basic env variables, some configurable
             > variables will be saved into $TOP/build/.config
	   3.2 $ bspsetup
		     > download and setup the toolchains
			 > download and setup kernel, u-boot and MM API SDK source code
			 > so that you can build them directly
	   3.3 $ l4tout_setup
		   	 > setup "64_TX1 --> Linux_for_Tegra_64_tx1" if it does not exist
	   3.4 $ kbuild
	   	     > build kernel source code, output to $TOP/out/KERNEL, $TOP/out/MODULES
			 > Copy the generated Image, dtb and modules into $OUT/kernel
	   3.5 $ kmenuconfig
	   	     > generate the menu of kernel defconfig
	   3.6 $ ksavedefconfig
             > save the kernel defconfig into $TOP/kernel/arch/arm64/$KERNEL_DEFCONFIG
	   3.7 $ ubuild
             > build u-boot source code, output to $OUT
             > copy the u-boot images into $OUT/
       3.8 $ flash
             > flash images with passing options to flash.sh
       3.9 $ kernel_dtb_update
             > Upload kernel and dtb files to TX1 device

	4. How to use normally
	   4.1 Initial setup
            After download files with Jetpack, run below commands to setup others:
		   		$ . build/envsetup.sh
				$ bspsetup
	   4.2 Normally use
	   	   		$ . build/envsetup.sh    --> this need to be run in any new shell				
				then you can build kernel, u-boot, etc with other commands.

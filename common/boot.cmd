# DO NOT EDIT THIS FILE
#
# Please edit /boot/uEnv.txt to set supported parameters
#

echo "Boot script loaded from ${devtype} ${devnum}:${distro_bootpart}."

setenv overlay_error "false"
setenv verbosity "7"

if test "${vendor}" = "amlogic"; then
	setenv load_addr "0x1600000"
elif test "${vendor}" = "rockchip"; then
	setenv load_addr "0x59000000"
fi

for p in ${boot_prefixes}; do
	if test -e ${devtype} ${devnum}:${distro_bootpart} ${p}boot.scr; then
		echo "Found boot.scr at ${p}."
		setenv prefix "${p}"
	fi
done

if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}uEnv.txt; then
	echo "Loading uEnv.txt..."
	load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}uEnv.txt
	env import -t ${load_addr} ${filesize}
fi

if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}.radxa; then
	echo "Loading .radxa..."
	load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}.radxa
	env import -t ${load_addr} ${filesize}
fi

setenv bootargs "root=UUID=${rootuuid} rootwait earlyprintk console=tty1 console=ttyAML0,115200n8 console=ttyFIQ0,1500000n8 panic=10 loglevel=${verbosity} cgroup_enable=cpuset cgroup_memory=1 cgroup_enable=memory swapaccount=1 ${extraargs} ${extraboardargs}"

echo "Loading ${initrdimg}..."
load ${devtype} ${devnum}:${distro_bootpart} ${ramdisk_addr_r} ${prefix}${initrdimg}

echo "Loading ${kernelimg}..."
load ${devtype} ${devnum}:${distro_bootpart} ${kernel_addr_r} ${prefix}${kernelimg}

echo "Loading ${fdtfile}..."
if load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}dtbs/${kernelversion}/${fdtfile}
then
	fdt addr ${fdt_addr_r}
	fdt resize 65536
	for overlay_file in ${overlays}; do
		if load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}dtbs/${kernelversion}/${vendor}/overlay/${overlay_file}.dtbo; then
			echo "Applying kernel provided DT overlay ${overlay_file}.dtbo"
			fdt apply ${load_addr} || setenv overlay_error "true"
		fi
	done
	for overlay_file in ${user_overlays}; do
		if load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}overlay-user/${overlay_file}.dtbo; then
			echo "Applying user provided DT overlay ${overlay_file}.dtbo"
			fdt apply ${load_addr} || setenv overlay_error "true"
		fi
	done
	if test "${overlay_error}" = "true"; then
		echo "Error applying DT overlays, restoring original DT"
		load ${devtype} ${devnum}:${distro_bootpart} ${fdt_addr_r} ${prefix}dtbs/${kernelversion}/${fdtfile}
	else
		if load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}dtbs/${kernelversion}/${vendor}/overlay/${soc}-fixup.scr; then
			echo "Applying kernel provided DT fixup script (${soc}-fixup.scr)"
			source ${load_addr}
		fi
		if test -e ${devtype} ${devnum}:${distro_bootpart} ${prefix}overlay-user/fixup.scr; then
			load ${devtype} ${devnum}:${distro_bootpart} ${load_addr} ${prefix}overlay-user/fixup.scr
			echo "Applying user provided fixup script (overlay-user/fixup.scr)"
			source ${load_addr}
		fi
	fi
else
	echo "Failed to load ${fdtfile} at ${fdt_addr_r}. Using backup fdt."
	setenv fdt_addr_r ${fdtcontroladdr}
fi

echo "Booting kernel..."
booti ${kernel_addr_r} ${ramdisk_addr_r}:${initrdsize} ${fdt_addr_r}

# Recompile with:
# mkimage -C none -A arm -T script -d /boot/boot.cmd /boot/boot.scr

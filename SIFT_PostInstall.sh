#!/bin/bash

if [ "$1" == "--help" ] || [ "$1" == "-h" ]; then
	echo "SIFT_PostInstall is a shell script to install additional tools in SIFT Workstation 3.0."
	echo "Please supply the virtualization engine to configure user access to Shared Folders in"
	echo "VirtualBox or to mount SharedFolders in VMware."
	echo
	echo "Usage: SIFT_PostInstall.sh [vbox|vmware]"
else
	# Install additional tools in SIFT Workstation 3.0
	sudo apt install -y libvmdk-tools lvm2 exiftool
	sudo pip install evtxtract
	
	sudo curl https://raw.githubusercontent.com/davidpany/WMI_Forensics/master/CCM_RUA_Finder.py -o /usr/local/bin/CCM_RUA_Finder.py
	sudo chmod 755 /usr/local/bin/CCM_RUA_Finder.py
	sudo curl https://raw.githubusercontent.com/davidpany/WMI_Forensics/master/PyWMIPersistenceFinder.py -o /usr/local/bin/PyWMIPersistenceFinder.py
	sudo chmod 755 /usr/local/bin/PyWMIPersistenceFinder.py
	
	sudo curl https://raw.githubusercontent.com/MarkBaggett/srum-dump/master/srum_dump.py -o /usr/local/bin/srum_dump.py
	sudo chmod 755 /usr/local/bin/srum_dump.py
	sudo curl https://raw.githubusercontent.com/MarkBaggett/srum-dump/master/srum_dump_csv.py -o /usr/local/bin/srum_dump_csv.py
	sudo chmod 755 /usr/local/bin/srum_dump_csv.py
	sudo curl https://github.com/MarkBaggett/srum-dump/raw/master/SRUM_TEMPLATE.xlsx -o /usr/local/bin/SRUM_TEMPLATE.xlsx
	sudo chmod 755 /usr/local/bin/SRUM_TEMPLATE.xlsx
	sudo curl https://github.com/MarkBaggett/srum-dump/raw/master/SRUM_TEMPLATE_SMALL.xlsx -o /usr/local/bin/SRUM_TEMPLATE_SMALL.xlsx
	sudo chmod 755 /usr/local/bin/SRUM_TEMPLATE_SMALL.xlsx
	
	sudo curl https://gist.githubusercontent.com/williballenthin/4494779/raw/ed895278e6ea5cee68da17775f9c9a22e97e1914/extract_all_i30.sh -o /usr/local/bin/extract_all_i30.sh
	sudo chmod 755 /usr/local/bin/extract_all_i30.sh
	
	git clone https://github.com/williballenthin/INDXParse.git /home/sansforensics/INDXParse
	cd /home/sansforensics/INDXParse
	python setup.py build
	sudo python setup.py install
	
	git clone https://github.com/williballenthin/shellbags.git /home/sansforensics/shellbags
	cd /home/sansforensics/shellbags
	python setup.py build
	sudo python setup.py install
	
	git clone https://github.com/williballenthin/python-ntfs.git /home/sansforensics/python-ntfs
	cd /home/sansforensics/python-ntfs
	python setup.py build
	sudo python setup.py install
fi

# Add sansforensics user to vboxsf group to allow user access to Shared Folders in VirtualBox
if [ "$1" == "vbox" ] || [ "$1" == "virtualbox" ]; then
	if groups sansforensics | grep &>/dev/null '\bvboxsf\b'; then
		echo "Warning: sansforensics is already a member of the vboxsf group"
	else
		echo "Information: Adding sansforensics to vboxsf"
		sudo usermod -a -G vboxsf sansforensics
	fi
fi

# Add the following line to /etc/fstab to automount Shared Folders in VMware (HGFS)
# .host:/	/mnt/hgfs	fuse.vmhgfs-fuse	allow_other	0	0
if [ "$1" == "vmware" ] || [ "$1" == "VMware" ]; then
	if grep -q '\/mnt\/hgfs' /etc/fstab; then
		echo "Warning: fstab already contains hgfs mount"
	else
		echo "Information: Adding hgfs mount to fstab"
		sudo bash -c 'echo -e ".host:/\t/mnt/hgfs\tfuse.vmhgfs-fuse\tallow_other\t0\t0" >> /etc/fstab'
	fi
fi

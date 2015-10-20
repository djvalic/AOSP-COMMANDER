#!/bin/bash

VERSION=.1a
HEIGHT=12
WIDTH=60
CHOICE_HEIGHT=4
BACKTITLE="AOSP Commander $VERSION"
AOSPVER="AOSP_60_MRA58K"
AOSPBRANCH="android-6.0.0_r1"
JCORES=8
EMAIL="me@you.com"
NAME="AOSP"

####FUNCTIONS########
#menus
menu_main() {
		OPTIONS=(
		  1 "Install required packages (Ubuntu 14.04)"
       		  2 "Configure Packages"
       		  3 "Repo Options"
       		  4 "AUTO AOSP INSTALL")
			CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
 	               --title "Main Menu" \
		       --cancel-label "Exit" \
 	               --menu "Choose one of the following options:" \
 	               $HEIGHT $WIDTH $CHOICE_HEIGHT \
 	               "${OPTIONS[@]}" \
 	               2>&1 >/dev/tty)
			case $CHOICE in
			1) get_packages
			;;
			2) menu_config
		    	;;
        		3) menu_repo
         	   	;;
        		4) auto_popup
         	   	;;
			esac
	}

menu_config() {
		OPTIONS=(
		  1 "Configure Java 7 defaults"
       		  2 "Configuring USB Access"
       		  3 "Optimize build environment")
			CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
 	               --title "Configure Packages" \
 	               --menu "Choose one of the following options:" \
 	               $HEIGHT $WIDTH 3 \
 	               "${OPTIONS[@]}" \
 	               2>&1 >/dev/tty)
			case $CHOICE in
			1) java_yesno
			;;
			2) conf_usb
		    	;;
        		3) conf_cache
         	   	;;
			esac
			menu_main
	}

menu_repo()  {
		OPTIONS=(
		  1 "Install Repo"
       		  2 "Initializ Repo client"
       		  3 "Sync/Download the Android Source Tree")
			CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
 	               --title "Repo Menu" \
 	               --menu "Choose one of the following repo options:" \
 	               $HEIGHT $WIDTH 3 \
 	               "${OPTIONS[@]}" \
 	               2>&1 >/dev/tty)
			case $CHOICE in
			1) repo_install && menu_repo
			;;
			2) repo_init $$ menu_repo
		    	;;
        		3) menu_repo-conf
         	   	;;
			esac
			menu_main
	}
#POPUPS
conf_cache() {
		dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "Optimize a build environment" \
		--yesno "Tell the build to use the ccache compilation tool? Ccache acts as a compiler cache that can be used to speed up rebuilds. Only works after repo sync is complete." 8 60 
			response=$?
			case $response in
  		 0) conf_cache_bashchache ;;
  		 1) menu_config ;;
  		 255) menu_config ;;
		esac
		menu_config
	}

conf_cache_bashchache() {
	echo "export USE_CCACHE=1">>~/.bashrc
	~/$AOSPVER/prebuilts/misc/linux-x86/ccache/ccache -M 50G
	~/$AOSPVER/prebuilt/linux-x86/ccache/ccache -M 50G
	}

conf_usb() {
	dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "Install USB Rules" \
		--yesno "Create a file at /etc/udev/rules.d/51-android.rules as the root user?" 6 60 
			response=$?
			case $response in
  		 0) conf_usb_get ;;
  		 1) menu_config ;;
  		 255) menu_config ;;
		esac
		menu_config
	}
conf_usb_get() {
	wget -S -O - http://source.android.com/source/51-android.rules | sed "s/$USER/$USER/" | sudo tee >/dev/null /etc/udev/rules.d/51-android.rules; sudo udevadm control --reload-rules
	}

java_yesno() {
            dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "Read Me" \
		--yesno "Use the fallowing to select java-7-oracle or java-7-openjdk" 6 60 
			response=$?
			case $response in
  		 0) java_config ;;
  		 1) menu_config ;;
  		 255) menu_config ;;
		esac
		menu_config
	}

java_config() {
		sudo update-alternatives --config java
		sudo update-alternatives --config javac
	}

get_packages() {
            dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "Install packages" \
		--yesno "Install All Required Packages For Ubuntu 14.04" 5 60 
			response=$?
			case $response in
  		 0) download_package ;;
  		 1) menu_main ;;
  		 255) menu_main ;;
		esac
		menu_main
	}
download_package() {
		sudo apt-get update && sudo apt-get -y install bison g++-multilib git gperf libxml2-utils make python-networkx zlib1g-dev:i386 zip openjdk-7-jdk phablet-tools git
		}

repo_install() {
	mkdir ~/bin
	PATH=~/bin:$PATH
	curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
	chmod a+x ~/bin/repo
	}

repo_init() {
	OPTIONS=(
       		  1 "android-6.0.0_r1  	  MRA58K"
       		  2 "android-5.1.1_r24	  LMY48W"
       		  3 "android-4.4.4_r2.0.1  KTU84Q"
		  4 "Master")
			CHOICE=$(dialog --clear \
	                --backtitle "$BACKTITLE" \
 	               --title "Initialize Repo Menu" \
 	               --menu "Choose one of the following repo options:" \
 	               $HEIGHT $WIDTH $CHOICE_HEIGHT \
 	               "${OPTIONS[@]}" \
 	               2>&1 >/dev/tty)
			case $CHOICE in
			1) 	AOSPBRANCH="android-6.0.0_r1"
				AOSPVER="AOSP_60_MRA58K" 
				repo_init_set
				menu_repo
			;;
			2)	AOSPBRANCH="android-5.1.1_r24"
				AOSPVER="AOSP_511_LMY48W" 
				repo_init_set
				menu_repo
		    	;;
        		3)	AOSPBRANCH="android-4.4.4_r2.0.1"
				AOSPVER="AOSP_444_KTU84Q" 
				repo_init_set
				menu_repo
         	   	;;
        		4)	AOSPBRANCH="master"
				AOSPVER="AOSP" 
				repo_init_set
				menu_repo
         	   	;;
			esac
			menu_repo
	}

repo_init_set() {
	mkdir ~/$AOSPVER
	cd ~/$AOSPVER
	git config user.email "$EMAIL"
	git config user.name "$NAME"
	git config --global color.ui auto
	git config --global color.branch auto
	git config --global color.status auto
	repo init -u https://android.googlesource.com/platform/manifest -b $AOSPBRANCH
	}
repo_sync() {
	cd ~/$AOSPVER
	repo sync -j$JCORES
	menu_repo
	}
menu_repo-conf() {
		dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "Repo Sync/Download" \
		--yesno "Are you sure you want to sync 11GB+ from AOSP servers? It could take a few hours depending on internet connection." 7 60 
			response=$?
			case $response in
  		 0) repo_sync ;;
  		 1) menu_repo ;;
  		 255) menu_repo ;;
		esac
		}
		
auto_popup() {
		dialog --clear \
                --backtitle "$BACKTITLE" \
		--title "AUTOMATIC INSTALLER" \
		--yesno "Will attept to intall a default $AOSPBRANCH AOSP. You will need to input your sudo password.  Syncing will take a few hours depending on internet connection." 7 60 
			response=$?
			case $response in
  		 0) auto_script ;;
  		 1) menu_main ;;
  		 255) menu_main ;;
		esac
		}		

auto_script() {
	download_package
	conf_usb_get
	repo_install
	repo_init_set
	repo_sync
	conf_cache_bashchache
	}

###SCRIPT START
clear
menu_main


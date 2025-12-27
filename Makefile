USERNAME=lajto  # Change the username if needed!
PLATFORM=desktop  # Alternative: vm

.if $(PLATFORM)==desktop
LOADERFILE=loader.conf
DEVFSCONFFILE=devfs.conf
FSTABFILE=fstab
RCFILE=rc.conf
SYSCTLFILE=sysctl.conf
XORGCONFDIR=xorg.conf.d
XINITRCFILE=.xinitrc
I3STATUSCONFIGFILE=config
.elif $(PLATFORM)==vm
LOADERFILE=loader-vm.conf
DEVFSCONFFILE=devfs-vm.conf
FSTABFILE=fstab-vm
RCFILE=rc-vm.conf
SYSCTLFILE=sysctl-vm.conf
XORGCONFDIR=xorg.conf.d-vm
XINITRCFILE=.xinitrc-vm
I3STATUSCONFIGFILE=config-vm
.endif


freebsd:
	# FreeBSD config files
	echo "LANG=en_US.UTF-8; export LANG" >> /etc/profile
	echo "CHARSET=UTF-8; export CHARSET" >> /etc/profile
	rm -f /boot/loader.conf && cp boot/$(LOADERFILE) /boot/loader.conf
	rm -f /etc/devfs.conf && cp etc/$(DEVFSCONFFILE) /etc/devfs.conf
	rm -f /etc/devfs.rules && cp etc/devfs.rules /etc/devfs.rules
	rm -f /etc/fstab && cp etc/$(FSTABFILE) /etc/fstab
	rm -f /etc/pf.conf && cp etc/pf.conf /etc/pf.conf
	rm -f /etc/rc.conf && cp etc/$(RCFILE) /etc/rc.conf
	rm -f /etc/sysctl.conf && cp etc/$(SYSCTLFILE) /etc/sysctl.conf
	# Add user to operator group (poweroff, reboot, mount...)
	pw groupmod operator -M $(USERNAME)
	pw groupmod wheel -M $(USERNAME)
	# Load Linux support
	kldload linux
	kldload linux64
	# Create dirs for mounting external USB devices
	mkdir -p /media/usb01
	chown $(USERNAME) /media/usb01
	mkdir -p /media/usb02
	chown $(USERNAME) /media/usb02
	mkdir -p /media/android
	chown $(USERNAME) /media/android
	# Create some dirs in user's /home
	mkdir -p /usr/home/$(USERNAME)/Screenshots
	chown $(USERNAME) /usr/home/$(USERNAME)/Screenshots
	mkdir -p /usr/home/$(USERNAME)/Repos
	chown $(USERNAME) /usr/home/$(USERNAME)/Repos
	mkdir -p /usr/home/$(USERNAME)/Downloads
	chown $(USERNAME) /usr/home/$(USERNAME)/Downloads
	mkdir -p /usr/home/$(USERNAME)/Documents
	chown $(USERNAME) /usr/home/$(USERNAME)/Documents
	# Start PF
	service pf start
	pfctl -f /etc/pf.conf

xorg:
	# Install Xorg
	pkg install x11/xorg
	# Xorg config
	cp -R usr/local/etc/X11/$(XORGCONFDIR) /usr/local/etc/X11/xorg.conf.d
	rm -f /usr/home/$(USERNAME)/.xinitrc
	cp usr/home/username/$(XINITRCFILE) /usr/home/$(USERNAME)/.xinitrc
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.xinitrc
	rm -f /usr/home/$(USERNAME)/.Xresources
	cp usr/home/username/.Xresources /usr/home/$(USERNAME)/.Xresources
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.Xresources
	mkdir -p /usr/home/$(USERNAME)/.icons/
	ln -s /usr/share/cursors/xorg-x11 /usr/home/$(USERNAME)/.icons
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.icons
	# GTK themes
	pkg install x11-themes/adwaita-icon-theme x11-themes/adwaita-qt \
	x11-themes/gtk-arc-themes x11-themes/gnome-themes-extra
	ln -s /usr/local/share/icons/Adwaita /usr/home/$(USERNAME)/.icons
	rm -f /usr/home/$(USERNAME)/.gtkrc-2.0
	cp usr/home/username/.gtkrc-2.0 /usr/home/$(USERNAME)/.gtkrc-2.0
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.gtkrc-2.0
	mkdir -p /usr/home/$(USERNAME)/.config/gtk-3.0
	rm -f /usr/home/$(USERNAME)/.config/gtk-3.0/settings.ini
	cp usr/home/username/.config/gtk-3.0/settings.ini \
	/usr/home/$(USERNAME)/.config/gtk-3.0/settings.ini

.if $(PLATFORM)==desktop
graphics:
	# NVIDIA
	pkg install x11/nvidia-driver
	pkg install x11/nvidia-settings
.elif $(PLATFORM)==vm
graphics:
	# VirtualBox addition packages
	pkg install emulators/virtualbox-ose-additions \
	x11-drivers/xf86-video-vmware
.endif

fonts:
	# Install fonts
	pkg install chinese/arphicttf chinese/font-std \
	hebrew/culmus hebrew/elmar-fonts japanese/font-ipa \
	japanese/font-ipa-uigothic japanese/font-ipaex japanese/font-kochi \
	japanese/font-migmix japanese/font-migu japanese/font-mona-ipa \
	japanese/font-motoya-al japanese/font-mplus-ipa japanese/font-sazanami \
	japanese/font-shinonome japanese/font-takao japanese/font-ume \
	japanese/font-vlgothic x11-fonts/hanazono-fonts-ttf \
	japanese/font-mikachan korean/aleefonts-ttf korean/nanumfonts-ttf \
	korean/unfonts-core x11-fonts/anonymous-pro x11-fonts/artwiz-aleczapka \
	x11-fonts/dejavu x11-fonts/inconsolata-ttf x11-fonts/terminus-font \
	x11-fonts/cantarell-fonts x11-fonts/droid-fonts-ttf x11-fonts/doulos \
	x11-fonts/ubuntu-font x11-fonts/isabella x11-fonts/junicode \
	x11-fonts/khmeros x11-fonts/padauk x11-fonts/stix-fonts \
	x11-fonts/charis x11-fonts/urwfonts-ttf russian/koi8r-ps \
	x11-fonts/geminifonts x11-fonts/cyr-rfx x11-fonts/paratype \
	x11-fonts/gentium-plus x11-fonts/sourcecodepro-ttf x11-fonts/noto \
	x11-fonts/roboto-fonts-ttf x11-fonts/powerline-fonts x11-fonts/hack-font \
	x11-fonts/intlfonts
	# Font config
	mkdir -p /usr/home/$(USERNAME)/.config/fontconfig
	cp usr/home/username/.config/fontconfig/fonts.conf \
	/usr/home/$(USERNAME)/.config/fontconfig/fonts.conf
	cd /usr/local/etc/fonts/conf.d; ln -s ../conf.avail/70-no-bitmaps.conf

i3wm:
	# Install i3wm along some useful software
	pkg install x11-wm/i3 x11/i3status x11/i3lock x11/dmenu \
	x11/rxvt-unicode graphics/scrot x11-wm/picom
	# i3wm config
	mkdir -p /usr/home/$(USERNAME)/.config/i3/
	rm -f /usr/home/$(USERNAME)/.config/i3/config
	cp usr/home/username/.config/i3/config \
	/usr/home/$(USERNAME)/.config/i3/config
	mkdir -p /usr/home/$(USERNAME)/.config/i3status/
	rm -f /usr/home/$(USERNAME)/.config/i3status/config
	cp usr/home/username/.config/i3status/$(I3STATUSCONFIGFILE) \
	/usr/home/$(USERNAME)/.config/i3status/config
	cp usr/home/username/.i3-wallpaper.png \
	/usr/home/$(USERNAME)/.i3-wallpaper.png
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.i3-wallpaper.png

update-i3:
	rm -f /usr/home/$(USERNAME)/.config/i3/config
	cp usr/home/username/.config/i3/config \
	/usr/home/$(USERNAME)/.config/i3/config
	rm -f /usr/home/$(USERNAME)/.config/i3status/config
	cp usr/home/username/.config/i3status/$(I3STATUSCONFIGFILE) \
	/usr/home/$(USERNAME)/.config/i3status/config


software:
	# File compression utilities
	pkg install archivers/zip archivers/unzip archivers/unrar \
	archivers/p7zip archivers/p7zip-codec-rar
	# NTFS
	pkg install sysutils/fusefs-ntfs
	# MTP (Android, iPhone...)
	pkg install sysutils/fusefs-simple-mtpfs
	# Terminal software
	pkg install sysutils/screenfetch sysutils/neofetch \
	sysutils/tmux sysutils/py-glances sysutils/py-ranger \
	multimedia/musikcube graphics/feh graphics/mupdf audio/mixertui \
	misc/cloc devel/tokei
	# Vim
	pkg install editors/vim
	rm -f /usr/home/$(USERNAME)/.vimrc
	wget -O /usr/home/$(USERNAME)/.vimrc \
	https://raw.githubusercontent.com/lajtomekadimon/vim-config/main/.vimrc
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.vimrc
	# wvim (my personal Vim launcher)
	cp usr/home/username/.wvim.sh /usr/home/$(USERNAME)/.wvim.sh
	chmod a+x /usr/home/$(USERNAME)/.wvim.sh
	ln -s /usr/home/$(USERNAME)/.wvim.sh /usr/bin/wvim
	# GUI software
	pkg install www/firefox x11-fm/pcmanfm graphics/eom \
	graphics/atril editors/mousepad net-p2p/transmission-gtk \
	archivers/engrampa multimedia/mpv editors/libreoffice
	# Japanese and Chinese keyboard support
	pkg install textproc/ibus japanese/ibus-mozc chinese/ibus-libpinyin

.if $(PLATFORM)==desktop
extra-software:
	# Image, sound and video edition
	pkg install graphics/gimp graphics/inkscape \
	audio/audacity audio/kid3-qt5 graphics/blender
	# Disc recorder
	pkg install sysutils/xfburn
	# Geogebra
	pkg install math/geogebra
	# KeePassXC
	pkg install security/keepassxc
	# Telegram Desktop
	pkg install net-im/telegram-desktop
	# Anki
	pkg install games/anki
	# Extra web browsers
	pkg install www/chromium
	# LaTeX
	pkg install print/texlive-full print/latex-biber
	# Video games
	pkg install games/0ad games/minetest emulators/dolphin-emu emulators/pcsxr
	# Webcam support
	pkg install multimedia/webcamd multimedia/v4l_compat multimedia/v4l-utils
	pw groupmod webcamd -m $(USERNAME)
	# VirtualBox
	pkg install emulators/virtualbox-ose
	pw groupmod vboxusers -m $(USERNAME)
.elif $(PLATFORM)==vm
extra-software:
	echo ""
.endif

configure: freebsd xorg graphics fonts i3wm software extra-software
	# Correct permissions for .config
	chown -R $(USERNAME) /usr/home/$(USERNAME)/.config

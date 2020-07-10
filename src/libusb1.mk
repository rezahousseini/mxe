# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := libusb1
$(PKG)_WEBSITE  := https://libusb.info/
$(PKG)_DESCR    := LibUsb-1.0
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := ad04734
$(PKG)_CHECKSUM := 4cf5bb8e33b576d8520fe622837a59e1214a76d5dacd04d7be567432accb7843
$(PKG)_GH_CONF  := libusb/libusb/branches/master
$(PKG)_DEPS     := cc

define $(PKG)_BUILD
    cd '$(1)' && ./bootstrap.sh && ./configure \
        $(MXE_CONFIGURE_OPTS) \
        CFLAGS=-D_WIN32_WINNT=0x0500
    $(MAKE) -C '$(1)' -j '$(JOBS)' install

    '$(TARGET)-gcc' \
        -W -Wall -Wextra -Werror \
        '$(TEST_FILE)' -o '$(PREFIX)/$(TARGET)/bin/test-libusb1.exe' \
        `'$(TARGET)-pkg-config' libusb-1.0 --cflags --libs`
endef

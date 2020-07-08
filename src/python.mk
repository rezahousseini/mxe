# This file is part of MXE. See LICENSE.md for licensing information.

PKG             := python
$(PKG)_WEBSITE  := https://www.python.org/
$(PKG)_IGNORE   :=
$(PKG)_basever  := 3.8
$(PKG)_VERSION  := $($(PKG)_basever).3
$(PKG)_CHECKSUM := dfab5ec723c218082fe3d5d7ae17ecbdebffa9a1aea4d64aa3a2ecdd2e795864
$(PKG)_SUBDIR   := Python-$($(PKG)_VERSION)
$(PKG)_FILE     := Python-$($(PKG)_VERSION).tar.xz
$(PKG)_URL      := https://www.python.org/ftp/python/$($(PKG)_VERSION)/$($(PKG)_FILE)
$(PKG)_URL_2    := 
$(PKG)_DEPS     := cc expat bzip2 libffi ncurses openssl sqlite $(BUILD)~tcl zlib xz
$(PKG)_TARGETS  := $(BUILD) $(MXE_TARGETS)

$(PKG)_DEPS_$(BUILD) :=

define $(PKG)_BUILD		
		# fix case
  	sed -e "s|MSTcpIP.h|mstcpip.h|g" -i $(SOURCE_DIR)/$($(PKG)_SOURCE_SUBDIR)/Modules/socketmodule.h
  	sed -e "s|Windows.h|windows.h|g" -i $(SOURCE_DIR)/$($(PKG)_SOURCE_SUBDIR)/Modules/_io/_iomodule.c
  	sed -e "s|VersionHelpers.h|versionhelpers.h|g" -i $(SOURCE_DIR)/$($(PKG)_SOURCE_SUBDIR)/Modules/socketmodule.c

		cd '$(SOURCE_DIR)/$($(PKG)_SOURCE_SUBDIR)' && autoreconf -vfi && \
			rm -r Modules/expat && rm -r Modules/_ctypes/{darwin,libffi}*
		
		# Workaround for conftest error on 64-bit builds
    export ac_cv_working_tzset=no

		cd '$(BUILD_DIR)' && '$(SOURCE_DIR)/configure' \
				--host=$(TARGET) \
				--build=$(BUILD) \
				$(if $(BUILD_STATIC), \
        	--disable-shared , \
        	--enable-shared ) \
				--prefix='$(PREFIX)/$(TARGET)' \
    		--with-system-expat \
				--with-nt-threads \
    		--with-system-ffi \
    		--without-system-libmpdec \
    		--without-ensurepip \
    		--enable-loadable-sqlite-extensions \
				--enable-optimizations \
    		--with-lto \
				CFLAGS="${CFLAGS} -fwrapv -D__USE_MINGW_ANSI_STDIO=1 -D_WIN32_WINNT=0x0601 -DNDEBUG -I$(PREFIX)/$(TARGET)/include" \
  			CXXFLAGS="${CXXFLAGS} -fwrapv -D__USE_MINGW_ANSI_STDIO=1 -D_WIN32_WINNT=0x0601 -DNDEBUG -I$(PREFIX)/$(TARGET)/include" \
    		CPPFLAGS="${CPPFLAGS} -I$(PREFIX)/$(TARGET)/include" \
    		LDFLAGS="${LDFLAGS} -L$(PREFIX)/$(TARGET)/lib"
		sed -e "s|windres|${TARGET}-windres|g" -i ${BUILD_DIR}/Makefile
    $(MAKE) -C '$(BUILD_DIR)' -j '$(JOBS)' $(MXE_DISABLE_CRUFT)
    $(MAKE) -C '$(BUILD_DIR)' -j 1 install DESTDIR=$(DESTDIR) $(MXE_DISABLE_CRUFT) \
			CC=$(TARGET)-gcc

	$(if $(BUILD_STATIC), \
		, \
		cp -f "$(PREFIX)/$(TARGET)/lib/python$($(PKG)_basever)/config-$($(PKG)_basever)/libpython$($(PKG)_basever).dll.a" "$(PREFIX)/$(TARGET)/lib/libpython$($(PKG)_basever).dll.a")
endef

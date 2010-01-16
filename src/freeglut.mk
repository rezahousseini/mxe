# This file is part of mingw-cross-env.
# See doc/index.html or doc/README for further information.

# freeglut
PKG             := freeglut
$(PKG)_IGNORE   := 2.6.0-rc3
$(PKG)_VERSION  := 2.6.0-rc1
$(PKG)_CHECKSUM := 0bf40f0134695a95032de8cf8305c13dc8d654e5
$(PKG)_SUBDIR   := freeglut-$(word 1,$(subst -, ,$($(PKG)_VERSION)))
$(PKG)_FILE     := freeglut-$($(PKG)_VERSION).tar.gz
$(PKG)_WEBSITE  := http://freeglut.sourceforge.net/
$(PKG)_URL      := http://$(SOURCEFORGE_MIRROR)/project/freeglut/freeglut/$(word 1,$(subst -, ,$($(PKG)_VERSION)))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc

define $(PKG)_UPDATE
    wget -q -O- 'http://freeglut.svn.sourceforge.net/viewvc/freeglut/tags/?sortby=date' | \
    grep '<a name="' | \
    $(SED) -n 's,.*<a name="FG_\([0-9][^"]*\)".*,\1,p' | \
    $(SED) 's,_RC,-rc,g; s,_,.,g' | \
    head -1
endef

define $(PKG)_BUILD
    $(SED) 's,Windows\.h,windows.h,'   -i '$(1)/src/freeglut_internal.h'
    $(SED) 's,WindowsX\.h,windowsx.h,' -i '$(1)/src/freeglut_internal.h'
    $(SED) 's,MMSystem\.h,mmsystem.h,' -i '$(1)/src/freeglut_internal.h'
    $(SED) 's,Windows\.h,windows.h,'   -i '$(1)/include/GL/freeglut_std.h'
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)/$(TARGET)' \
        --enable-replace-glut \
        --disable-debug \
        --without-progs \
        --without-x
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef

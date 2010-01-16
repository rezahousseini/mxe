# This file is part of mingw-cross-env.
# See doc/index.html or doc/README for further information.

# libgsf
PKG             := libgsf
$(PKG)_IGNORE   :=
$(PKG)_VERSION  := 1.14.16
$(PKG)_CHECKSUM := 9461d816c283e977d88916932def678560f9c8d5
$(PKG)_SUBDIR   := libgsf-$($(PKG)_VERSION)
$(PKG)_FILE     := libgsf-$($(PKG)_VERSION).tar.bz2
$(PKG)_WEBSITE  := http://ftp.gnome.org/pub/gnome/sources/libgsf/
$(PKG)_URL      := http://ftp.gnome.org/pub/gnome/sources/libgsf/$(call SHORT_PKG_VERSION,$(PKG))/$($(PKG)_FILE)
$(PKG)_DEPS     := gcc zlib bzip2 glib libxml2

define $(PKG)_UPDATE
    wget -q -O- -U 'mingw-cross-env' 'http://freshmeat.net/projects/libgsf/' | \
    grep 'libgsf/releases' | \
    $(SED) -n 's,.*<a href="/projects/libgsf/releases/[^"]*">\([0-9][^<]*\)</a>.*,\1,p' | \
    head -1
endef

define $(PKG)_BUILD
    # Don't search for intltool
    $(SED) 's,\(INTLTOOL_APPLIED_VERSION\)=.*,\1=0.35.0,' -i '$(1)/configure'
    $(SED) 's,^\(INTLTOOL_UPDATE\)=.*,\1=disabled,' -i '$(1)/configure'
    $(SED) 's,^\(INTLTOOL_MERGE\)=.*,\1=disabled,' -i '$(1)/configure'
    $(SED) 's,^\(INTLTOOL_EXTRACT\)=.*,\1=disabled,' -i '$(1)/configure'
    $(SED) 's,require XML::Parser,,' -i '$(1)/configure'
    # build
    cd '$(1)' && ./configure \
        --host='$(TARGET)' \
        --disable-shared \
        --prefix='$(PREFIX)/$(TARGET)' \
        --disable-nls \
        --disable-gtk-doc \
        --disable-schemas-install \
        --without-python \
        --without-gnome-vfs \
        --without-bonobo \
        --with-zlib \
        --with-bz2 \
        --with-gio \
        PKG_CONFIG='$(PREFIX)/bin/$(TARGET)-pkg-config'
    $(MAKE) -C '$(1)' -j '$(JOBS)' install bin_PROGRAMS= sbin_PROGRAMS= noinst_PROGRAMS=
endef

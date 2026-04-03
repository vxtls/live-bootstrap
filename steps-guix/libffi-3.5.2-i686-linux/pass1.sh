# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

ARCH_PREFIX=/usr/guix-bootstrap/i686-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib

src_prepare() {
    rm doc/libffi.{pdf,info}

    autoreconf-2.71 -fi
}

src_configure() {
    ./configure \
        --prefix="${ARCH_PREFIX}" \
        --libdir="${ARCH_LIBDIR}" \
        --build="${TARGET}" \
        --host="${TARGET}" \
        --disable-shared \
        --with-gcc-arch=generic \
        --enable-pax_emutramp
}

# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

ARCH_PREFIX=/usr/guix-bootstrap/i686-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib

src_prepare() {
    autoreconf-2.71 -fi
}

src_configure() {
    # CFLAGS needed on musl
    ./configure \
        --prefix="${ARCH_PREFIX}" \
        --libdir="${ARCH_LIBDIR}" \
        --build="${TARGET}" \
        --host="${TARGET}" \
        --disable-shared \
        CFLAGS='-D_GNU_SOURCE -DNO_GETCONTEXT -DSEARCH_FOR_DATA_START -DUSE_MMAP -DHAVE_DL_ITERATE_PHDR'
}

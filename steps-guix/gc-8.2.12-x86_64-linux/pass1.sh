# SPDX-FileCopyrightText: 2021 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

: "${CROSS_TARGET:=x86_64-unknown-linux-musl}"
: "${CROSS_SYSROOT:=/x86_64-linux-cross}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

ARCH_PREFIX=/usr/guix-bootstrap/x86_64-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib

src_prepare() {
    autoreconf-2.71 -fi
}

src_configure() {
    # CFLAGS needed on musl
    CC="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-gcc" \
    AR="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ar" \
    RANLIB="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ranlib" \
    ./configure \
        --prefix="${ARCH_PREFIX}" \
        --libdir="${ARCH_LIBDIR}" \
        --build="${BUILD_TARGET}" \
        --host="${CROSS_TARGET}" \
        --disable-shared \
        CFLAGS='-D_GNU_SOURCE -DNO_GETCONTEXT -DSEARCH_FOR_DATA_START -DUSE_MMAP -DHAVE_DL_ITERATE_PHDR'
}

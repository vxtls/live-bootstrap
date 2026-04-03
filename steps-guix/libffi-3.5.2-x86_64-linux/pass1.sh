# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
#
# SPDX-License-Identifier: GPL-3.0-or-later

: "${CROSS_TARGET:=x86_64-unknown-linux-musl}"
: "${CROSS_SYSROOT:=/x86_64-linux-cross}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

ARCH_PREFIX=/usr/guix-bootstrap/x86_64-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib

src_prepare() {
    rm doc/libffi.{pdf,info}

    autoreconf-2.71 -fi
}

src_configure() {
    CC="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-gcc" \
    AR="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ar" \
    RANLIB="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ranlib" \
    ./configure \
        --prefix="${ARCH_PREFIX}" \
        --libdir="${ARCH_LIBDIR}" \
        --build="${BUILD_TARGET}" \
        --host="${CROSS_TARGET}" \
        --disable-shared \
        --with-gcc-arch=generic \
        --enable-pax_emutramp
}

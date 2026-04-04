# SPDX-License-Identifier: GPL-3.0-or-later

# Build argp-standalone for the kernel toolchain sysroot. This is used by
# later kernel-side dependencies (for example elfutils).
: "${KERNEL_TARGET:=x86_64-unknown-linux-musl}"
: "${KERNEL_SYSROOT:=/kernel-toolchain}"

src_prepare() {
    default
    autoreconf -fi
}

src_configure() {
    mkdir build
    cd build

    # argp-standalone's testsuite expects argp.h from source root even when
    # building out-of-tree.
    CPPFLAGS="-I${PWD}/.." \
    CC="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-gcc" \
    AR="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ar" \
    RANLIB="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ranlib" \
    ../configure \
        --build="${TARGET}" \
        --host="${KERNEL_TARGET}" \
        --prefix="${KERNEL_SYSROOT}" \
        --libdir="${KERNEL_SYSROOT}/lib"
}

src_compile() {
    default_src_compile
}

src_install() {
    mkdir -p "${DESTDIR}${KERNEL_SYSROOT}/include"
    mkdir -p "${DESTDIR}${KERNEL_SYSROOT}/lib"

    # noinst_HEADERS/noinst_LIBRARIES: install artifacts explicitly.
    install -m644 ../argp.h "${DESTDIR}${KERNEL_SYSROOT}/include/argp.h"
    install -m644 libargp.a "${DESTDIR}${KERNEL_SYSROOT}/lib/libargp.a"
}

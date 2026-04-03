# SPDX-License-Identifier: GPL-3.0-or-later

: "${KERNEL_TARGET:=x86_64-unknown-linux-musl}"
: "${KERNEL_SYSROOT:=/kernel-toolchain}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

src_prepare() {
    default
}

src_configure() {
    CC="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-gcc" \
    AR="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ar" \
    RANLIB="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ranlib" \
    ./configure \
        --build="${BUILD_TARGET}" \
        --host="${KERNEL_TARGET}" \
        --disable-shared \
        --prefix="${KERNEL_SYSROOT}" \
        --libdir="${KERNEL_SYSROOT}/lib" \
        --includedir="${KERNEL_SYSROOT}/include"

    if test -f /dev/null; then
        rm /dev/null
        mknod -m 666 /dev/null c 1 3
    fi
}

src_compile() {
    make "${MAKEJOBS}" CROSS_COMPILE="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-"
}

src_install() {
    make DESTDIR="${DESTDIR}" install

    if [ -e "${DESTDIR}/lib/ld-musl-x86_64.so.1" ]; then
        rm -f "${DESTDIR}/lib/ld-musl-x86_64.so.1"
        rmdir "${DESTDIR}/lib" 2>/dev/null || true
    fi

    ln -sf libc.so "${DESTDIR}${KERNEL_SYSROOT}/lib/ld-musl-x86_64.so.1"
}

src_postprocess() {
    :
}

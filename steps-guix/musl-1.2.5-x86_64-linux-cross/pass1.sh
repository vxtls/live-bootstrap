# SPDX-License-Identifier: GPL-3.0-or-later

: "${CROSS_TARGET:=x86_64-unknown-linux-musl}"
: "${CROSS_SYSROOT:=/x86_64-linux-cross}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

src_prepare() {
    default
}

src_configure() {
    CC="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-gcc" \
    AR="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ar" \
    RANLIB="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ranlib" \
    ./configure \
        --build="${BUILD_TARGET}" \
        --host="${CROSS_TARGET}" \
        --disable-shared \
        --prefix="${CROSS_SYSROOT}" \
        --libdir="${CROSS_SYSROOT}/lib" \
        --includedir="${CROSS_SYSROOT}/include"

    if test -f /dev/null; then
        rm /dev/null
        mknod -m 666 /dev/null c 1 3
    fi
}

src_compile() {
    make "${MAKEJOBS}" CROSS_COMPILE="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-"
}

src_install() {
    make DESTDIR="${DESTDIR}" install

    if [ -e "${DESTDIR}/lib/ld-musl-x86_64.so.1" ]; then
        rm -f "${DESTDIR}/lib/ld-musl-x86_64.so.1"
        rmdir "${DESTDIR}/lib" 2>/dev/null || true
    fi

    ln -sf libc.so "${DESTDIR}${CROSS_SYSROOT}/lib/ld-musl-x86_64.so.1"
}

src_postprocess() {
    :
}

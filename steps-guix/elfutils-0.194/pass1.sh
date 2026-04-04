# SPDX-License-Identifier: GPL-3.0-or-later

# Build elfutils against kernel-toolchain dependencies.
: "${KERNEL_TARGET:=x86_64-unknown-linux-musl}"
: "${KERNEL_SYSROOT:=/kernel-toolchain}"

src_prepare() {
    default

    # Regenerate autotools outputs from source metadata.
    AUTOMAKE=automake-1.15 \
    ACLOCAL=aclocal-1.15 \
    AUTOCONF=autoconf-2.69 \
    AUTOHEADER=autoheader-2.69 \
    autoreconf-2.69 -fi
}

src_configure() {
    mkdir build
    cd build

    PKG_CONFIG_PATH="${KERNEL_SYSROOT}/lib/pkgconfig:${KERNEL_SYSROOT}/share/pkgconfig" \
    PKG_CONFIG_LIBDIR="${KERNEL_SYSROOT}/lib/pkgconfig:${KERNEL_SYSROOT}/share/pkgconfig" \
    CPPFLAGS="-I${KERNEL_SYSROOT}/include" \
    CFLAGS="-Wno-error=unused-but-set-variable" \
    LDFLAGS="-L${KERNEL_SYSROOT}/lib" \
    CC="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-gcc" \
    AR="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ar" \
    RANLIB="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ranlib" \
    ../configure \
        --prefix="${KERNEL_SYSROOT}" \
        --libdir="${KERNEL_SYSROOT}/lib" \
        --includedir="${KERNEL_SYSROOT}/include" \
        --build="${TARGET}" \
        --host="${KERNEL_TARGET}" \
        --disable-textrelcheck \
        --disable-debuginfod \
        --disable-libdebuginfod
}

src_compile() {
    LD_LIBRARY_PATH="${KERNEL_SYSROOT}/lib:${LD_LIBRARY_PATH}" \
    make "${MAKEJOBS}" \
        LDFLAGS="-L${KERNEL_SYSROOT}/lib -Wl,-rpath-link,${KERNEL_SYSROOT}/lib" \
        LIBS="-lfts -lobstack -largp"
}

src_install() {
    make "${MAKEJOBS}" install \
        DESTDIR="${DESTDIR}" \
        prefix="${KERNEL_SYSROOT}" \
        libdir="${KERNEL_SYSROOT}/lib" \
        includedir="${KERNEL_SYSROOT}/include"
}

# SPDX-License-Identifier: GPL-3.0-or-later

# Build musl-fts for the kernel toolchain sysroot.
: "${KERNEL_TARGET:=x86_64-unknown-linux-musl}"
: "${KERNEL_SYSROOT:=/kernel-toolchain}"

src_prepare() {
    default
    autoreconf -fi
}

src_configure() {
    mkdir build
    cd build

    CC="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-gcc" \
    AR="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ar" \
    RANLIB="${KERNEL_SYSROOT}/bin/${KERNEL_TARGET}-ranlib" \
    ../configure \
        --build="${TARGET}" \
        --host="${KERNEL_TARGET}" \
        --prefix="${KERNEL_SYSROOT}" \
        --libdir="${KERNEL_SYSROOT}/lib" \
        --includedir="${KERNEL_SYSROOT}/include"
}

src_compile() {
    default_src_compile
}

src_install() {
    make "${MAKEJOBS}" install \
        DESTDIR="${DESTDIR}" \
        prefix="${KERNEL_SYSROOT}" \
        libdir="${KERNEL_SYSROOT}/lib" \
        includedir="${KERNEL_SYSROOT}/include"
}

# SPDX-License-Identifier: GPL-3.0-or-later

: "${CROSS_TARGET:=x86_64-unknown-linux-musl}"
: "${CROSS_SYSROOT:=/x86_64-linux-cross}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

ARCH_SYSTEM=x86_64-linux
ARCH_PREFIX=/usr/guix-bootstrap/x86_64-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib
ARCH_PKG_CONFIG=${ARCH_LIBDIR}/pkgconfig:${ARCH_PREFIX}/share/pkgconfig
NATIVE_GUILE_PREFIX=/usr/guix-bootstrap/i686-linux

src_prepare() {
    local p

    for p in "${patch_dir}"/*.patch; do
        echo "Applying patch: ${p}"
        patch -Np1 < "${p}"
    done

    AUTOPOINT=true \
    ACLOCAL_PATH="${PREFIX}/share/aclocal:${PREFIX}/share/gettext/m4${ACLOCAL_PATH:+:${ACLOCAL_PATH}}" \
    autoreconf -fi

    sed -i \
        -e 's|^guile_LDADD =.*$|guile_LDADD = libguile-@GUILE_EFFECTIVE_VERSION@.la -ldl|' \
        -e 's|^guile_LDFLAGS =.*$|guile_LDFLAGS = -all-static|' \
        libguile/Makefile.in
}

src_configure() {
    local libffi_cflags libffi_libs native_guile native_guild

    native_guile="${NATIVE_GUILE_PREFIX}/bin/guile"
    native_guild="${NATIVE_GUILE_PREFIX}/bin/guild"

    libffi_cflags="$(
        PKG_CONFIG_LIBDIR="${ARCH_PKG_CONFIG}" \
        PKG_CONFIG_PATH="${ARCH_PKG_CONFIG}" \
        pkg-config --cflags libffi
    )"
    libffi_libs="$(
        PKG_CONFIG_LIBDIR="${ARCH_PKG_CONFIG}" \
        PKG_CONFIG_PATH="${ARCH_PKG_CONFIG}" \
        pkg-config --static --libs libffi
    )"

    PATH="${NATIVE_GUILE_PREFIX}/bin:${PATH}" \
    GUILE="${native_guile}" \
    GUILE_FOR_BUILD="${native_guile}" \
    GUILD="${native_guild}" \
    GUILD_FOR_BUILD="${native_guild}" \
    CC="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-gcc" \
    AR="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ar" \
    RANLIB="${CROSS_SYSROOT}/bin/${CROSS_TARGET}-ranlib" \
    PKG_CONFIG_LIBDIR="${ARCH_PKG_CONFIG}" \
    PKG_CONFIG_PATH="${ARCH_PKG_CONFIG}" \
    CPPFLAGS="-I${ARCH_PREFIX}/include" \
    CFLAGS="${CFLAGS:-} -std=gnu89" \
    LDFLAGS="-L${ARCH_LIBDIR} -ldl" \
    LIBFFI_CFLAGS="${libffi_cflags}" \
    LIBFFI_LIBS="${libffi_libs}" \
    ./configure \
        --build="${BUILD_TARGET}" \
        --host="${CROSS_TARGET}" \
        --prefix="${ARCH_PREFIX}" \
        --libdir="${ARCH_LIBDIR}" \
        --disable-shared \
        --enable-static \
        --enable-mini-gmp
}

src_compile() {
    PATH="${NATIVE_GUILE_PREFIX}/bin:${PATH}" make -j1
}

src_install() {
    local install_root stage stage_ccache version tarball_name

    version=2.0
    install_root="${DESTDIR}${ARCH_PREFIX}"
    tarball_name="guile-static-stripped-2.0.9-${ARCH_SYSTEM}.tar.xz"
    stage="${DESTDIR}/bootstrap-seeds/${ARCH_SYSTEM}/guile-2.0.9"
    stage_ccache="${stage}/lib/guile/${version}/ccache"

    PATH="${NATIVE_GUILE_PREFIX}/bin:${PATH}" make DESTDIR="${DESTDIR}" install

    mkdir -p "${stage}/bin"
    mkdir -p "${stage}/share/guile/${version}"
    mkdir -p "${stage_ccache}"

    cp "${install_root}/bin/guile" "${stage}/bin/guile"
    cp -r "${install_root}/share/guile/${version}/." "${stage}/share/guile/${version}/"
    cp -r "${install_root}/lib/guile/${version}/ccache/." "${stage_ccache}/"

    seed_make_repro_tar_xz "${stage}" "${DISTFILES}/${tarball_name}"
}

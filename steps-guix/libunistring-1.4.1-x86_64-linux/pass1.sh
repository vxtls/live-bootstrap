# SPDX-FileCopyrightText: 2022 Andrius Štikonas <andrius@stikonas.eu>
# SPDX-FileCopyrightText: 2026 Samuel Tyler <samuel@samuelt.me>
#
# SPDX-License-Identifier: GPL-3.0-or-later

: "${CROSS_TARGET:=x86_64-unknown-linux-musl}"
: "${CROSS_SYSROOT:=/x86_64-linux-cross}"
: "${BUILD_TARGET:=${TARGET:-i686-unknown-linux-musl}}"

ARCH_PREFIX=/usr/guix-bootstrap/x86_64-linux
ARCH_LIBDIR=${ARCH_PREFIX}/lib

src_prepare() {
    default

    find . \( -name '*.info*' -o -name "*.html" \) -delete

    local GNULIB
    GNULIB=../gnulib-6d64a31
    rm lib/unictype/*_byname.h \
        lib/unicase/locale-languages.h \
        lib/iconv_open-*.h
    rm {$GNULIB,.}/lib/unictype/{digit,pr_*,ctype_*,categ_*,combiningclass,numeric,blocks,[bij]*_of,sy_*,scripts,decdigit,mirror}.h
    rm {$GNULIB,.}/lib/unictype/scripts_byname.gperf \
        {$GNULIB,.}/lib/uniwbrk/wbrkprop.h \
        {$GNULIB,.}/lib/uniwidth/width*.h \
        {$GNULIB,.}/lib/unimetadata/u-version.c \
        {$GNULIB,.}/lib/uninorm/{decomposition-table[12].h,composition-table.gperf,composition-table-bounds.h} \
        lib/uninorm/composition-table.h \
        {$GNULIB,.}/lib/unigbrk/gbrkprop.h \
        {$GNULIB,.}/lib/uniname/uninames.h \
        {$GNULIB,.}/lib/unilbrk/{lbrkprop[12].h,lbrktables.c} \
        {$GNULIB,.}/lib/unicase/{special-casing-table.*,to*.h,ignorable.h,cased.h}
    find {$GNULIB,.}/tests/{unicase,unigbrk,unictype} -name "test-*.{c,h}" -delete -exec touch {} +
    touch $GNULIB/lib/uniname/uninames.h

    mv gen-uninames.py "$GNULIB/lib"
    pushd "$GNULIB/lib"
    mv ../../*.txt .
    gcc -Iunictype -o gen-uni-tables gen-uni-tables.c
    ./gen-uni-tables UnicodeData-17.0.0.txt \
        PropList-17.0.0.txt \
        DerivedCoreProperties-17.0.0.txt \
        emoji-data-17.0.0.txt \
        ArabicShaping-17.0.0.txt \
        Scripts-17.0.0.txt \
        Blocks-17.0.0.txt \
        PropList-3.0.1.txt \
        BidiMirroring-17.0.0.txt \
        EastAsianWidth-17.0.0.txt \
        LineBreak-17.0.0.txt \
        WordBreakProperty-17.0.0.txt \
        GraphemeBreakProperty-17.0.0.txt \
        CompositionExclusions-17.0.0.txt \
        SpecialCasing-17.0.0.txt \
        CaseFolding-17.0.0.txt \
        17.0.0
    python3 gen-uninames.py \
        UnicodeData-17.0.0.txt NameAliases-17.0.0.txt \
        uniname/uninames.h
    popd

    # libunistring does not specify which gnulib snapshot was used,
    # pick a random one that works
    GNULIB_SRCDIR=$GNULIB ./autogen.sh

    # autogen.sh does not regenerate libtool files
    autoreconf -fi
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
        --disable-shared
}

#!/usr/bin/env bash


rm -rf ffmpeg_arm_build
mkdir -p ffmpeg_arm_build
cd ffmpeg_arm_build

#LD_RUN_PATH=path on nas to load libraries from /opt/lib:/opt/local/lib

ARM_DIR=`pwd`/../arm_build
ARM_LIBDIR=${ARM_DIR}/lib
ARM_INCLUDEDIR=${ARM_DIR}/include
ARM_BINDIR=${ARM_DIR}/bin


FAAC_VERSION=1.28
#FFMPEG_VERSION=0.11.2
FFMPEG_VERSION=1.0

GNUEABI_PREFIX=arm-linux-gnueabi
#GNUEABI_PREFIX=arm-none-eabi

export CFLAGS="-I/opt/local/include"
export LDFLAGS="-L/opt/local/lib"

AR=${GNUEABI_PREFIX}-ar
CC=${GNUEABI_PREFIX}-gcc
CXX=${GNUEABI_PREFIX}-cpp
LD=${GNUEABI_PREFIX}-ld
RANLIB=${GNUEABI_PREFIX}-ranlib


# Faac (Mpeg4 audio coding)
echo "================================================================"
echo "FAAC - MPEG-4 AAC audio coder"
echo "================================================================"
wget http://downloads.sourceforge.net/faac/faac-${FAAC_VERSION}.tar.gz
tar xzf faac-${FAAC_VERSION}.tar.gz
cd faac-*
CC=${GNUEABI_PREFIX}-gcc ./configure --prefix=${ARM_DIR} --host=arm-linux-gnueabi --with-mp4v2=no --enable-static --disable-shared  || exit 1;
make -j4  || exit 1;
make install || exit 1;
cd ..



#x264
echo ""
echo "================================================================"
echo "x264 video coder"
echo "================================================================"
wget ftp://ftp.videolan.org/pub/x264/snapshots/last_x264.tar.bz2
tar xjf last_x264.tar.bz2
cd x264-snapshot*
./configure --cross-prefix=${GNUEABI_PREFIX}- --prefix=${ARM_DIR} --enable-pic --enable-static --disable-shared --disable-cli --disable-asm --host=arm-linux  || exit 1;
make -j4 || exit 1;
make install || exit 1;
cd ..

# ffmpeg
echo ""
echo "================================================================"
echo "ffmpeg"
echo "================================================================"
wget http://ffmpeg.org/releases/ffmpeg-snapshot.tar.bz2
tar xjf ffmpeg-snapshot.tar.bz2
#wget http://ffmpeg.org/releases/ffmpeg-${FFMPEG_VERSION}.tar.gz
#tar xzf ffmpeg-*.tar.gz
cd ffmpeg*

#MARCH=-march=armv5te
PKG_CONFIG_PATH=${ARM_LIBDIR}/pkgconfig/
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/local/arm-linux-gnueabi/lib
#
./configure --enable-cross-compile \
    --prefix=${ARM_DIR} \
    --arch=arm5vte \
    --enable-armv5te \
    --disable-armv6 \
    --target-os=linux \
    --cross-prefix=${GNUEABI_PREFIX}- \
    --disable-doc \
    --disable-stripping \
    --disable-mmx \
    --disable-neon \
    --enable-version3 \
    --enable-static \
    --disable-shared \
    --disable-debug \
    --pkg-config=pkg-config \
    --enable-pthreads \
    --enable-gpl \
    --enable-memalign-hack \
    --enable-decoder=h264 \
    --enable-demuxer=mov \
    --enable-muxer=mp4 \
    --enable-encoder=libx264 \
    --enable-libx264 \
    --enable-libfaac --enable-nonfree \
    --enable-protocol=file \
    --enable-decoder=aac \
    --enable-encoder=aac \
    --disable-ffplay \
    --disable-ffprobe \
    --disable-ffserver \
    --disable-network \
    --enable-filter=buffer \
    --enable-filter=buffersink \
    --enable-filter=scale \
    --enable-runtime-cpudetect \
    --enable-hwaccels \
    --enable-zlib \
    --disable-demuxer=v4l \
    --disable-demuxer=v4l2 \
    --disable-indev=v4l \
    --disable-indev=v4l2 \
    --extra-cflags="-I${ARM_INCLUDEDIR} -fPIC -D__thumb__ -mthumb -Wfatal-errors -Wno-deprecated" \
    --extra-ldflags="-L${ARM_LIBDIR} -Wl,-rpath=/opt/lib -Wl,-rpath=/opt/local/lib" \
    --extra-libs="-lgcc"  || exit 1;

        #--disable-everything \
        #     --cxx=${CXX} \
        #     --ar=${AR} \
        #     --as=${AS} \
        #   --enable-yasm \
        #

        #    --cc=${CC} \
        #    --ld=${LD} \



make -j4 || exit 1;
make install || exit 1;

cd ..

echo "Done"
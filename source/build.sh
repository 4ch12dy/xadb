# export CC=i686-linux-android-clang
# export CXX=i686-linux-android-clang++

# PWD=`pwd`

# $CXX mprop.cpp -o mprop -static  -l$PWD/x86_M/libc.a -l$PWD/x86_M/libdl.a
# $NDK/build/tools/make_standalone_toolchain.py --arch arm --install-dir=/tmp/my-android-toolchain

# add to terminal PATH variable
export PATH=~/xia0/android/tools/xia0Toolchain/bin:$PATH

# make alias CC be the new gcc binary
export CC=aarch64-linux-android-gcc

# compile your C code(I tried hello world)
$CC -march=armv8-a -fPIE -D__ANDROID_API__=21 -pie -o mprop mprop.c
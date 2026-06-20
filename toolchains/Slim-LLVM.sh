#!/bin/bash

maindir="$(pwd)"
outside="${maindir}/.."

dir="${outside}/Slim-Llvm"

case $1 in
  "setup" )
    if [[ ! -d "${dir}/bin" ]]; then
      mkdir -p "${dir}" && cd "${dir}"
      LATEST_URL="https://www.kernel.org/pub/tools/llvm/files/llvm-22.1.8-x86_64.tar.xz"

      echo "Downloading Slim LLVM..."
      curl -Lo a.tar.xz "$LATEST_URL"
      
      echo "Extracting and stripping components directly into ${dir}..."
      tar -xf a.tar.xz --strip-components=1
      
      rm -f a.tar.xz
      cd - > /dev/null
    fi
  ;;
  
  "build" )
    export PATH="${dir}/bin:${PATH}"
    
    make -j$NJOBS O=out CC=clang LD=ld.lld ARCH=arm64 SUBARCH=arm64 $2
    make -j$NJOBS O=out olddefconfig
    
    make -j$NJOBS O=out \
      ARCH=arm64 \
      SUBARCH=arm64 \
      LLVM=1 \
      LLVM_IAS=1 \
      CLANG_TRIPLE="aarch64-linux-gnu-" \
      CROSS_COMPILE="aarch64-linux-gnu-" \
      CROSS_COMPILE_ARM32="arm-linux-gnueabi-" \
      CROSS_COMPILE_COMPAT="arm-linux-gnueabi-" \
      CC=clang \
      LD=ld.lld \
      NM=llvm-nm \
      AR=llvm-ar \
      STRIP=llvm-strip \
      OBJCOPY=llvm-objcopy \
      OBJDUMP=llvm-objdump \
      READELF=llvm-readelf \
      HOSTCC=clang \
      HOSTCXX=clang++ \
      HOSTLD=ld.lld \
      HOSTAR=llvm-ar \
      2>&1 | tee ${CUR_TOOLCHAIN}.log
    sh ${outside}/ver_toolchain.sh clang ld.lld > ${CUR_TOOLCHAIN}.info
    ;;
esac


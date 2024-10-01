# syntax = docker/dockerfile:1.2

FROM archlinux

# install packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Syu --noconfirm --needed base base-devel git

# configure nvidia container runtime
# https://github.com/NVIDIA/nvidia-container-runtime#environment-variables-oci-spec
ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES all

RUN pacman-key --refresh-keys

RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Syy --noconfirm

RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -Syu --noconfirm --needed archlinux-keyring ca-certificates

# Install other packages that aren't the most recent in the Arch repos
# mostly LLVM / Clang related
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -U --noconfirm \
    https://archive.archlinux.org/packages/c/clang/clang-17.0.6-2-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/c/compiler-rt/compiler-rt-17.0.6-2-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/libc++/libc%2B%2B-17.0.6-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/libc++abi/libc%2B%2Babi-17.0.6-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/lld/lld-17.0.6-1-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/lldb/lldb-17.0.6-2-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/llvm/llvm-17.0.6-5-x86_64.pkg.tar.zst \
    https://archive.archlinux.org/packages/l/llvm-libs/llvm-libs-17.0.6-5-x86_64.pkg.tar.zst

# Install Nvidia Utils 555.58.02
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -U --noconfirm https://archive.archlinux.org/packages/n/nvidia-utils/nvidia-utils-555.58.02-1-x86_64.pkg.tar.zst

# Install Nvidia proprietary driver 555.58.02
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -U --noconfirm https://archive.archlinux.org/packages/n/nvidia/nvidia-555.58.02-9-x86_64.pkg.tar.zst

# Install OpenCL Nvidia 555.58.02
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -U --noconfirm https://archive.archlinux.org/packages/o/opencl-nvidia/opencl-nvidia-555.58.02-1-x86_64.pkg.tar.zst

# Install CUDA 12.5
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -U --noconfirm https://archive.archlinux.org/packages/c/cuda/cuda-12.5.1-1-x86_64.pkg.tar.zst

# Install add'l packages
RUN --mount=type=cache,sharing=locked,target=/var/cache/pacman \
    pacman -S --noconfirm --needed \    
    cmake \
    cudnn \
    ffmpeg \
    fmt \    
    glew \
    hdf5 \
    intel-oneapi-mkl \
    intel-oneapi-tbb \
    libxcb \
    libxkbcommon-x11 \
    magma-cuda \
    mold \
    nasm \
    nccl \
    ninja \
    opencv-cuda \
    openmpi \
    python-opencv \
    python-pytorch-opt-cuda \
    python-torchvision-cuda \
    qt6-5compat \
    qt6-base \
    qt6-wayland \
    ruff \
    torchvision-cuda \
    uasm \
    uv \
    vtk \
    wget \
    xcb-imdkit \
    xcb-proto \
    xcb-util \
    xcb-util-cursor \
    xcb-util-errors \
    xcb-util-image \
    xcb-util-keysyms \
    xcb-util-renderutil \
    xcb-util-wm \
    xcb-util-xrm \
    yasm

# yay
RUN mkdir -p /tmp/yay-build && \
  useradd -m -G wheel builder && passwd -d builder && \
  chown -R builder:builder /tmp/yay-build

RUN echo 'builder ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

RUN su - builder -c "git clone https://aur.archlinux.org/yay.git /tmp/yay-build/yay"

RUN su - builder -c "cd /tmp/yay-build/yay && makepkg -irs --noconfirm"

# TensorRT 10.4 is compatible with any CUDA version between 12.0 & 12.6
RUN su - builder -c "yay -S --noconfirm cusparselt tensorrt python-tensorrt matplotplusplus"

RUN userdel -r builder

# Install Kineto Lib
WORKDIR /Build
RUN git clone -b v0.4.0 --single-branch --recursive https://github.com/pytorch/kineto.git
RUN sed -i "10i #include <cstdint>\n" kineto/libkineto/src/SampleListener.h
RUN cd kineto/libkineto && \
    mkdir build && \
    cd build && \
    cmake -D CMAKE_C_COMPILER=clang -D CMAKE_CXX_COMPILER=clang++ -D CUDA_SOURCE_DIR=/opt/cuda -D CUPTI_INCLUDE_DIR=/opt/cuda/extras/CUPTI/include -D CUDA_cupti_LIBRARY=/opt/cuda/extras/CUPTI/lib64/libcupti.so -W no-dev -G Ninja .. && \
    ninja && \
    ninja install

WORKDIR /root

# Cleanup
RUN rm -rf /Build && \
    rm -rf /var/cache/pacman/*

RUN rm -rf /tmp/yay-build

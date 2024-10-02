# Arch Linux based Docker container for PyTorch / OpenCV

This repository contains a Dockerfile to build a Docker image with PyTorch and OpenCV installed.  
The image is based on the official Arch Linux image using the Nvidia 555 driver with CUDA 12.5, since currently that's the officially supported driver + CUDA combo available in the default **Ubuntu 24.04 LTS** repos.  
This image is meant to be run within a host that's the above mentioned Ubuntu version.

## Contents

Some of the key components of the image are:

| Component | Version |
| --------- | ------- |
|_Arch Linux_ base image|kernel **6.10.10**|
|_Nvidia driver_|**555.58.02**|
|_CUDA_|**12.5.1**|
|_cuDNN_|**9.2.1.18**|
|_NCCL_|**2.21.5**|
|_Python_|**3.12.6**|
|_LLVM_|**17.0.6**|
|_Protobuf_|**27.3**|
|_PyTorch_ / _LibTorch_|**2.3.1**|
|_OpenCV_|**4.10**|

## Building the image

In bash:

```shell
docker build --progress=plain -t arch-nvidia555-cuda125-pytorch:$(date +%Y%m%d_%H%M%S) .
```

In fish:

```shell
docker build --progress=plain -t arch-nvidia555-cuda125-pytorch:(date +%Y%m%d_%H%M%S) .
```

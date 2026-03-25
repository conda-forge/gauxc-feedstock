#!/usr/bin/env bash

set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  CUDA=ON
  #CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=60;70;75;80;86;89;90;100;120 ${CMAKE_ARGS}"
  CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=80 ${CMAKE_ARGS}"
  #CMAKE_BUILD_PARALLEL_LEVEL=1
else
  CUDA=OFF
fi
if [ "${mpi}" != "nompi" ]; then
  MPI=ON
else
  MPI=OFF
fi 

if [ "${mpi}" == "openmpi" ]; then
  export OMPI_MCA_plm=isolated
  export OMPI_MCA_btl_vader_single_copy_mechanism=none
  export OMPI_MCA_rmaps_base_oversubscribe=yes
fi

cmake \
   -S . \
   -B _build \
   -G Ninja \
   -DGAUXC_ENABLE_HOST=ON \
   -DGAUXC_ENABLE_CUDA=${CUDA} \
   -DGAUXC_ENABLE_HIP=OFF \
   -DGAUXC_ENABLE_MPI=${MPI} \
   -DGAUXC_ENABLE_OPENMP=ON \
   -DGAUXC_ENABLE_GAU2GRID=ON \
   -DGAUXC_ENABLE_HDF5=ON \
   -DBUILD_SHARED_LIBS=ON \
   ${CMAKE_ARGS}
cmake --build _build
cmake --install _build

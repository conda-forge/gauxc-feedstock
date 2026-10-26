#!/usr/bin/env bash

set -ex

if [[ ${cuda_compiler_version} != "None" ]]; then
  CUDA=ON
  echo CUDAARCHS= $CUDAARCHS

  if [[ ${cuda_compiler_version} == 12.* ]]; then
      export CMAKE_CUDA_ARCHS="60-real;70-real;75-real;80-real;86-real;89-real;90a-real;100f-real;120a-real;121f-real;121-virtual"
  elif [[ ${cuda_compiler_version} == 13.* ]]; then
      # CUDA 13 dropped Maxwell/Pascal/Volta; minimum supported arch is Turing (75).
      export CMAKE_CUDA_ARCHS="75-real;80-real;86-real;89-real;90a-real;100f-real;120a-real;121f-real;121-virtual"
  fi
  CMAKE_ARGS="-DCMAKE_CUDA_ARCHITECTURES=${CMAKE_CUDA_ARCHS} ${CMAKE_ARGS}"
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

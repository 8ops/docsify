#!/bin/bash

. /etc/profile
rm -rf downloads logs results; mkdir -p downloads logs results

G3C_HOME=/data/G3C
export MCRROOT=${G3C_HOME}/.matlab/v715/
LD_LIBRARY_PATH=.:${MCRROOT}/runtime/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/bin/glnxa64 ;
LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRROOT}/sys/os/glnxa64;
      MCRJRE=${MCRROOT}/sys/java/jre/glnxa64/jre/lib/amd64 ;
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/native_threads ; 
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/server ;
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE}/client ;
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${MCRJRE} ;  
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:${G3C_HOME}/lib ;
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/lib64;
      LD_LIBRARY_PATH=${LD_LIBRARY_PATH}:/usr/local/lib:/usr/local/cuda;
export G3C_GPU=0
XAPPLRESDIR=${MCRROOT}/X11/app-defaults ;
export LD_LIBRARY_PATH;
export XAPPLRESDIR;
export MCR_CACHE_ROOT=/dev/shm/mcr_$RANDOM;
mkdir $MCR_CACHE_ROOT;

java -jar run_g3c_Main.jar







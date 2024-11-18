#!/bin/bash


export SNPSLMD_LICENSE_FILE=27020@172.21.99.41
export SYNOPSYS_HOME=/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys
export VCS_HOME=/mnt/vol_NFS_alajuela/qtree_NFS_rh003/synopsys_tools/synopsys/vcs-mx/O-2018.09-SP2-3
export PATH=$PATH:$VCS_HOME/linux64/bin

echo $SNPSLMD_LICENSE_FILE
echo $SYNOPSYS_HOME
echo $VCS_HOME
echo $PATH

echo [INFO] End of exporting.sh

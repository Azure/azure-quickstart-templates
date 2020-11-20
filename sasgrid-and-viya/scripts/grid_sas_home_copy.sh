#!/bin/bash
set -x
echo "*** Phase 4 Grid HomeCopy Script Started at `date +'%Y-%m-%d_%H-%M-%S'` ***"

## Function for error handling
fail_if_error() {
  [ $1 != 0 ] && {
    echo $2
    exit 10
  }
}

# Variables
depot_loc=`facter sasdepot_folder`
app_name=`facter application_name`
sas_role=`facter sas_role`
domain_name=`facter domain_name`

# Copy the sashome installed on localFS to Lustre
cd /tmp/sashome_temp; time tar -cf sashome.tar sashome
fail_if_error $? "Error:Tar failed"
cd /tmp/sashome_temp; time cp -pr sashome.tar /opt/sas/grid/
fail_if_error $? "Error:Tar copy failed"
cd /opt/sas/grid; time tar -xf sashome.tar
fail_if_error $? "Error:untar failed" 

echo "*** Phase 4 - Grid HomeCopy Script Ended at `date +'%Y-%m-%d_%H-%M-%S'` ***"
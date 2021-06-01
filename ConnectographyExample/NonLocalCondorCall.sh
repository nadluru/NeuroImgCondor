#!/bin/bash
source ../Utilities/CondorFunctions.sh
for volid in `cat volids.txt`
do
# initializing condor variables
export studyDir=/path/to/fod/and/atlasindwi/and/5TTdata
export mrtrix3=/path/to/mrtrix3StaticCompile/mrtrix3

export job=${volid}_connectograph
export executable=$(pwd)/Connectograph_Gordon_NonLocalCondor.sh
export args=$volid
export numCPUs="1"
export RAM="16 Gb"
export disk="500 Gb"

export initialDir=NonLocalCondorLogs_Gordon_Connectograph
mkdir -p $initialDir
export transferInputFiles="$studyDir/GordonReg_${volid}/${volid}_Gordon_regions_in_DWI.nii.gz,$studyDir/wmfod_${volid}_norm.mif,$studyDir/${volid}_mprageInDWI_5TT.mif,$mrtrix3"
export transferOutputFiles="mu_Gordon_${volid}.txt,connectome_Gordon_${volid}.csv,meanlength_Gordon_${volid}.csv,exemplars_${volid}.tck,nodes_${volid}_smooth.obj"

NonLocalCondorEcho
done
#! /bin/bash

# mrtrix3 setup
export PATH=$(pwd)/mrtrix3/bin:$PATH
export HOME=$(pwd)
chmod -R a=wrx $(pwd)/mrtrix3/bin

echo "TmpFileDir: $(pwd)" > $(pwd)/.mrtrix.conf
echo "Analyse.LeftToRight: false" >> $(pwd)/.mrtrix.conf
echo "NumberOfThreads: 1" >> $(pwd)/.mrtrix.conf
echo "ScriptTmpDir: $(pwd)" >> $(pwd)/.mrtrix.conf

# variable initialization
volid=$1
atlas=${volid}_Gordon_regions_in_DWI.nii.gz
fodwm=wmfod_${volid}_norm.mif
fiveTT=${volid}_mprageInDWI_5TT.mif

tractogram=tracogram_Gordon_${volid}.tck
weights=weights_Gordon_${volid}.csv
mu=mu_Gordon_${volid}.txt
connectome=connectome_Gordon_${volid}.csv
assignments=assignments_Gordon_${volid}.csv
meanlength=meanlength_Gordon_${volid}.csv

numThreads=16
numNodes=333
numStreamlines=$(echo "1500 * $numNodes * ($numNodes-1)" | bc)

# with 5TT
tckgen $fodwm $tractogram -act $fiveTT -backtrack -crop_at_gmwmi -maxlength 250 -power 0.33 -select $numStreamlines -seed_dynamic $fodwm -force -nthreads $numThreads
tcksift2 $tractogram $fodwm $weights -act $fiveTT -out_mu $mu -fd_scale_gm -force -nthreads $numThreads
tck2connectome $tractogram $atlas $connectome -tck_weights_in $weights -force -nthreads $numThreads
tck2connectome $tractogram $atlas $meanlength -tck_weights_in $weights -scale_length -stat_edge mean -force -nthreads $numThreads

# Generating geometric data for enhanced connectome visualisation
connectome2tck $tractogram $assignments exemplars_${volid}.tck -tck_weights_in $weights -exemplars $atlas -files single -force
label2mesh $atlas nodes_${volid}.obj
meshfilter nodes_${volid}.obj smooth nodes_${volid}_smooth.obj

# cleanup
rm -rf $tractogram $weights $assignments nodes_${volid}.obj $mrtrix3
# Om Shanti. Om Sai Ram. March 9, 2015. 3:41 p.m. Madison, WI.

allMFiles=''
for i in `ls *.m`; do allMFiles=${allMFiles},`echo $i`; echo $i; done
# Copy paste from console

chtc_mcc --mfiles={copy pasted comma separated m files} --mtargets=NODDIFittingCondor.m --stderr

batch_fitting.m,batch_fitting_single.m,BesselJ_RootsCyl.m,ChunkROICondor.m,CreateROI.m,CylNeumanLePar_PGSE.m,CylNeumanLePerp_PGSE.m,DT_DesignMatrix.m,erfi.m,EstimateSigma.m,FitLinearDT.m,fmincon_fix.m,fobj_rician_fix.m,fobj_rician.m,fobj_rician_st.m,FSL2Protocol.m,GetB0.m,GetB_Values.m,GetFibreOrientation.m,GetParameterIndex.m,GetParameterStrings.m,GetScalingFactors.m,GetSearchGrid.m,GradDescDecode.m,GradDescEncode.m,GradDescLimits.m,GridSearchRician.m,LegendreGaussianIntegral.m,logbesseli0.m,MakeDT_Matrix.m,MakeModel.m,NODDIFittingCondor.m,NumFreeParams.m,PackageChunkROICondor.m,PlotFittedModel.m,RemoveNegMeas.m,RicianLogLik.m,SaveAsNIfTI.m,SaveParamsAsNIfTI.m,SchemeToProtocol.m,SynthMeasHinderedDiffusion_PGSE.m,SynthMeasIsoGPD.m,SynthMeas.m,SynthMeasWatsonHinderedDiffusion_PGSE.m,SynthMeasWatsonSHCylNeuman_PGSE.m,SynthMeasWatsonSHCylSingleRadGPD.m,SynthMeasWatsonSHCylSingleRadGPD_PGSE.m,SynthMeasWatsonSHCylSingleRadIsoV_GPD_B0.m,SynthMeasWatsonSHCylSingleRadIsoV_GPD.m,SynthMeasWatsonSHCylSingleRadIsoVIsoDot_GPD_B0.m,SynthMeasWatsonSHCylSingleRadIsoVIsoDot_GPD.m,SynthMeasWatsonSHCylSingleRadTortGPD.m,SynthMeasWatsonSHCylSingleRadTortIsoV_GPD_B0.m,SynthMeasWatsonSHCylSingleRadTortIsoV_GPD.m,SynthMeasWatsonSHCylSingleRadTortIsoVIsoDot_GPD_B0.m,SynthMeasWatsonSHCylSingleRadTortIsoVIsoDot_GPD.m,SynthMeasWatsonSHStickIsoV_B0.m,SynthMeasWatsonSHStickIsoVIsoDot_B0.m,SynthMeasWatsonSHStickTortIsoV_B0.m,SynthMeasWatsonSHStickTortIsoVIsoDot_B0.m,ThreeStageFittingVoxel.m,VoxelDataViewer.m,WatsonHinderedDiffusionCoeff.m,WatsonSHCoeff.m

About to do this compile: <<mcc -m -R -singleCompThread -R -nodisplay -R -nojvm NODDIFittingCondor.m>>

# Om Shanti. Om Sai Ram. March 9, 2015. 4:48 p.m. Madison, WI.
mcc -m -R -singleCompThread -R -nodisplay -R -nojvm -a . NODDIFittingCondor.m

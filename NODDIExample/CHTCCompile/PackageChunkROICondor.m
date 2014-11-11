function PackageChunkROICondor(ROIFile, model, progressStepSize, inRoot, outputFile)

%
% function batch_fitting(roifile, protocol, model, outputfile, poolsize)
%
% Chunking the ROI file into sub-directories for being run on condor. Based
% off of batch_fitting.m from NODDI toolbox by Gary Hui Zhang.
%
% Input:
%
% ROIFile: the ROI file created with CreateROI
%
% progressStepSize: the step size with which chunking was done. Has to
% match that in ChunkROICondor.m
%
% inRoot: the path to the root folder under which the sub-directories with
% output from Condor were created.
%
% outputFile: File to which the fitted parameters and quality of the fit
% are saved.
%
% author: Nagesh Adluru (nagesh.adluru@gmail.com)
%

% if this is the first run
currentSplitStart = 1;

% load the roi file
load(ROIFile);
numOfVoxels = size(roi,1);
fprintf('%i of voxels to package\n', numOfVoxels  -currentSplitStart+1);

% set up the fitting parameter variables if it is the first run
gsps = zeros(numOfVoxels, model.numParams);
mlps = zeros(numOfVoxels, model.numParams);
fobj_gs = zeros(numOfVoxels, 1);
fobj_ml = zeros(numOfVoxels, 1);
error_code = zeros(numOfVoxels, 1);
if model.noOfStages == 3
    mcmcps = zeros(numOfVoxels, model.MCMC.samples, model.numParams + 1);
end

numChunks = 0;
for splitStart = currentSplitStart:progressStepSize:numOfVoxels
    fprintf('\nPacking chunk %d from the root %s', splitStart, inRoot);
    splitEnd = splitStart + progressStepSize - 1;
    if splitEnd > numOfVoxels
        splitEnd = numOfVoxels;
    end
    load(sprintf('%s/Job%d/NODDIFitChunk.mat', inRoot, numChunks + 1));
    gsps(splitStart:splitEnd, :) = NODDIFitChunk.gsps;
    fobj_gs(splitStart:splitEnd) = NODDIFitChunk.fobj_gs;
    mlps(splitStart:splitEnd, :) = NODDIFitChunk.mlps;
    fobj_ml(splitStart:splitEnd) = NODDIFitChunk.fobj_ml;
    error_code(splitStart:splitEnd) = NODDIFitChunk.error_code;
    if model.noOfStages == 3
        mcmcps(splitStart:splitEnd, :, :) = NODDIFitChunk.mcmcps;
    end
    numChunks = numChunks + 1;
end

% save the fitted parameters
if model.noOfStages == 2
    save(outputFile, 'model', 'gsps', 'fobj_gs', 'mlps', 'fobj_ml', 'error_code');
else
    save(outputFile, 'model', 'gsps', 'fobj_gs', 'mlps', 'fobj_ml', 'mcmcps', 'error_code');
end
return
function ChunkROICondor(ROIFile, progressStepSize, outRoot, cleanChunkDirs)

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
% progressStepSize: the step size with which to chunk the voxels.
%
% outRoot: the path to the root folder under which the sub-directories will
% be created.
%
% cleanChunkDirs: Boolean variable indicating if old chunk directories need
% to be deleted. If set to 1 deletes the job folders from outRoot first
% before creating new ones.
%
% author: Nagesh Adluru (nagesh.adluru@gmail.com)
%

% if this is the first run
currentSplitStart = 1;

% load the roi file
load(ROIFile);
numOfVoxels = size(roi,1);
fprintf('%i of voxels to chunk\n', numOfVoxels - currentSplitStart+1);

if(cleanChunkDirs)
    RunOnUnix(sprintf('rm -rf %s/Job*', outRoot));
end

numChunks = 0;
for splitStart = currentSplitStart:progressStepSize:numOfVoxels
    fprintf('\nSaving chunk %d to the root %s', splitStart, outRoot);
    splitEnd = splitStart + progressStepSize - 1;
    if splitEnd > numOfVoxels
        splitEnd = numOfVoxels;
    end
    chunk = roi(splitStart:splitEnd,:)';
    RunOnUnix(sprintf('mkdir %s/Job%d', outRoot, numChunks + 1));
    save(sprintf('%s/Job%d/chunk.mat', outRoot, numChunks + 1), 'chunk');
    numChunks = numChunks + 1;
end
fprintf('\nTotal number of chunks (jobs) created=%d', numChunks);
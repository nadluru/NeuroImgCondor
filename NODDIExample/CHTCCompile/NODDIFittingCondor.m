function [NODDIFitChunk]=NODDIFittingCondor(chunkFile, protocolFile, modelFile)

%
% function [noddi_fit_chunk]=noddi_fitting_condor(chunk, protocol, model)
%
% This function does fitting to the voxels in an entire chunk created with
% ChunkROICondor function based off of Gary Hui Zhang's batch_fitting.m
%
% Input:
%
% chunkFile: the chunk file created with ChunkROICondor
%
% protocolFile: the protocol object created with FSL2Protocol
%
% modelFile: the model object created with MakeModel
%
%
% author: Nagesh Adluru (nagesh.adluru@gmail.com)
%


% load the roi file
load(chunkFile)
numOfVoxels = size(chunk, 2);
fprintf('%i of voxels to fit\n', numOfVoxels);
load(protocolFile)
load(modelFile)
model=noddi;
%model
% set up the fitting parameter variables if it is the first run
gsps = zeros(numOfVoxels, model.numParams);
mlps = zeros(numOfVoxels, model.numParams);
fobj_gs = zeros(numOfVoxels, 1);
fobj_ml = zeros(numOfVoxels, 1);
error_code = zeros(numOfVoxels, 1);
if model.noOfStages == 3
    mcmcps = zeros(numOfVoxels, model.MCMC.samples, model.numParams + 1);
end


% fit the split
for i=1:numOfVoxels
    
    % get the MR signals for the voxel i
    voxel = chunk(:,i);
    
    % fit the voxel
    if model.noOfStages == 2
        [gsps(i,:), fobj_gs(i), mlps(i,:), fobj_ml(i), error_code(i)] = ThreeStageFittingVoxel(voxel, protocol, model);
    else
        [gsps(i,:), fobj_gs(i), mlps(i,:), fobj_ml(i), error_code(i), mcmcps(i,:,:)] = ThreeStageFittingVoxel(voxel, protocol, model);
    end
end

% package the results of the chunk
NODDIFitChunk.gsps = gsps;
NODDIFitChunk.fobj_gs = fobj_gs;
NODDIFitChunk.mlps = mlps;
NODDIFitChunk.fobj_ml = fobj_ml;
NODDIFitChunk.error_code = error_code;
if model.noOfStages == 3
    NODDIFitChunk.mcmcps=mcmcps;
end
save('NODDIFitChunk.mat', 'NODDIFitChunk');
return
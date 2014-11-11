% Makesure your Matlab session is started on a valid CHTC submit
% node like (For e.g., medusa.keck.waisman.wisc.edu and submit.chtc.wisc.edu).

clear all;
close all;

%% Initializing variables.
workshopRoot = '/study/aa-scratch/Nagesh/CondorWorkshop';
CHTCFilesRoot = sprintf('%s/CHTCFiles', workshopRoot);
compiledCodeRoot = sprintf('%s/NODDIExample/CHTCCompile', workshopRoot);
compiledCodeName = 'NODDIFittingCondor';

NODDIDataRoot = sprintf('%s/NODDIExample/NODDI_example_dataset', workshopRoot);
bvalFile = sprintf('%s/NODDI_protocol.bval', NODDIDataRoot);
bvecFile = sprintf('%s/NODDI_protocol.bvec', NODDIDataRoot);
dwi = sprintf('%s/NODDI_DWI.hdr', NODDIDataRoot);
mask = sprintf('%s/brain_mask.hdr', NODDIDataRoot);

chunkSize = 1000;

%% Adding necessary paths.
addpath(sprintf('%s/Utilities', workshopRoot));
addpath(compiledCodeRoot);

%% Organizing input and command.
% Creating the root directory.
inputRoot = sprintf('/scratch/%s', compiledCodeName);
if(~exist(inputRoot, 'dir'))
    RunOnUnix(sprintf('mkdir %s', inputRoot));
end

% Creating directories for each job.
% Create one job per slice.
% Clean first.
RunOnUnix(sprintf('rm -rf %s/Job*', inputRoot));

%Create and chunk the ROI.
NODDIROIFile = sprintf('%s/NODDIROI.mat', NODDIDataRoot);
CreateROI(dwi, mask, NODDIROIFile);
ChunkROICondor(NODDIROIFile, chunkSize, inputRoot, false);

% Copying the compiled executable, protocol and noddi (model) to the shared directory.
RunOnUnix(sprintf('rm -rf %s/shared', inputRoot));
RunOnUnix(sprintf('mkdir %s/shared', inputRoot));
RunOnUnix(sprintf('cp %s/%s %s/shared', compiledCodeRoot, compiledCodeName, inputRoot));
protocol = FSL2Protocol(bvalFile, bvecFile);
noddi = MakeModel('WatsonSHStickTortIsoV_B0');
save(sprintf('%s/shared/protocol.mat', inputRoot), 'protocol');
save(sprintf('%s/shared/noddi.mat', inputRoot), 'noddi');
fprintf('\n Data preparation complete!');

%% Organizing the output and condor files.
% Creating the output directory.
outputRoot = sprintf('/scratch/%sOutput', compiledCodeName);
RunOnUnix(sprintf('rm -rf %s', outputRoot));

% Copying relevant CHTC code over to parent directory of the input
% directory.
RunOnUnix(sprintf('cp %s/mkdag /scratch', CHTCFilesRoot));
RunOnUnix(sprintf('cp %s/process.template /scratch', CHTCFilesRoot));
RunOnUnix(sprintf('cp %s/chtcjobwrapper /scratch', CHTCFilesRoot));
RunOnUnix(sprintf('cp %s/postjob.template /scratch', CHTCFilesRoot));

% Moving to the parent directory of the input directory (because of the way mkdag prepends to the paths).
cd('/scratch');
% Generating the DAG.
RunOnUnix(sprintf('./mkdag --cmdtorun=%s --data=%s --dagdir=%sOutput --pattern=NODDIFitChunk.mat --parg=chunk.mat --parg=protocol.mat --parg=noddi.mat --type=Matlab', compiledCodeName, compiledCodeName, compiledCodeName));

%% Submit condor jobs.
% Submitting the DAG.
cd(sprintf('%s', outputRoot));
RunOnUnix(sprintf('condor_submit_dag mydag.dag'));

%% Collecting the output. (Run this part after the condor jobs are completed.)
% NODDIFit = sprintf('%s/NODDIFittedParamsFromCondor.mat', NODDIDataRoot);
% NODDIMeasurePrefix = sprintf('%s/NODDIMeasureFromCondor', NODDIDataRoot);

% Collect NODDI fits from chunked ROIs and put them back together.
% PackageChunkROICondor(NODDIROIFile, noddi, chunkSize, outputRoot, NODDIFit);

%Convert the estimated NODDI parameters into volumetric parameter maps
% SaveParamsAsNIfTI(NODDIFit, NODDIROIFile, mask, NODDIMeasurePrefix);

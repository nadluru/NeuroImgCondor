% Makesure your Matlab session is started on a valid CHTC submit
% node like (For e.g., medusa.keck.waisman.wisc.edu and submit.chtc.wisc.edu).

clear all;
close all;

%% Initializing variables.
workshopRoot = '/study/aa-scratch/Nagesh/CondorWorkshop';
CHTCFilesRoot = sprintf('%s/CHTCFiles', workshopRoot);
compiledCodeRoot = sprintf('%s/VIPRIRExample/CHTCCompile', workshopRoot);
compiledCodeName = 'fit_t1_alpha_beta_irssCondor';

VIPRIRDataRoot = sprintf('%s/VIPRIRExample/FRAMES/', workshopRoot);
% Load relevant information about the frames.
load([VIPRIRDataRoot 'info_file_vox_old.mat']);
happyFlag = happy;
numSlices = 240;
startSlice = 115;
endSlice = 116;

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

for sliceNum = startSlice:endSlice
    % Load the VIPRIR slice for all frames.
    ir_imgs = real(read_cpx_viprir_imgs(happyFlag, sliceNum, VIPRIRDataRoot));
    % Load the SPGR slice for all alphas.
    ss_imgs = zeros(size(ir_imgs,1), size(ir_imgs,2), numel(alpha_ss));
    for x=1:numel(alpha_ss)
        fname = [VIPRIRDataRoot sprintf('SS_%02d.cpx',alpha_ss(x))];
        ss_imgs(:,:,x) = real(read_cpx_img_slice(happyFlag, sliceNum, fname));
    end
    % Load the mask slice.
    mask_name = [VIPRIRDataRoot sprintf('Complex_Image_Frame_%03d_V_%03d.dat',0,0)];
    mask = create_mask( abs(real(read_cpx_img(happyFlag.rcyres,happyFlag.rcxres,happyFlag.rczres,mask_name))),threshold,fsize );
    mask = mask(:,:,sliceNum);
    
    RunOnUnix(sprintf('mkdir %s/Job%d', inputRoot, sliceNum));
    
    inputParametersFile = sprintf('%s/Job%d/inputParameters.mat', inputRoot, sliceNum);
    save(inputParametersFile, 'ir_imgs', 'ss_imgs', 'mask');
end
fprintf('\n Data preparation complete!');

% Copying the compiled executable, happyFlag and alpha_ss to the shared directory.
RunOnUnix(sprintf('rm -rf %s/shared', inputRoot));
RunOnUnix(sprintf('mkdir %s/shared', inputRoot));
RunOnUnix(sprintf('cp %s/%s %s/shared', compiledCodeRoot, compiledCodeName, inputRoot));
sharedParametersFile = sprintf('%s/shared/sharedParameters.mat', inputRoot);
save(sharedParametersFile, 'happyFlag', 'alpha_ss');

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
RunOnUnix(sprintf('./mkdag --cmdtorun=%s --data=%s --dagdir=%sOutput --pattern=T1RhoAlphaMapBetaMap.mat --parg=inputParameters.mat --parg=sharedParameters.mat --type=Matlab', compiledCodeName, compiledCodeName, compiledCodeName));

%% Submit condor jobs.
% Submitting the DAG.
cd(sprintf('%s', outputRoot));
RunOnUnix(sprintf('condor_submit_dag mydag.dag'));

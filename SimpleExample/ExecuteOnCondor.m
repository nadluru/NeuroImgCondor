% Makesure your Matlab session is started on a valid CHTC submit
% node like (For e.g., medusa.keck.waisman.wisc.edu and submit.chtc.wisc.edu).

clear all;
close all;

%% Initializing variables.
pairs = randn(100,2);
workshopRoot = '/study/aa-scratch/Nagesh/CondorWorkshop';
CHTCFilesRoot = sprintf('%s/CHTCFiles', workshopRoot);
compiledCodeRoot = sprintf('%s/SimpleExample', workshopRoot);
compiledCodeName = 'MultiplyTwoNumbers';

%% Adding necessary paths.
addpath(sprintf('%s/Utilities/', workshopRoot));

% To compare to the output produced by executing on condor.
productLocal = prod(pairs, 2);

%% Organizing input and command.
% Creating the root directory.
inputRoot = sprintf('/scratch/%s', compiledCodeName);
if(~exist(inputRoot, 'dir'))
    RunOnUnix(sprintf('mkdir %s', inputRoot));
end

% Creating directories for each job.
% Clean first.
RunOnUnix(sprintf('rm -rf %s/Job*', inputRoot));
for i = 1:size(pairs, 1)
    RunOnUnix(sprintf('mkdir %s/Job%d', inputRoot, i));
    
    inputPairFile = sprintf('%s/Job%d/inputPair.mat', inputRoot, i);
    a = pairs(i, 1);
    b = pairs(i, 2);
    save(inputPairFile, 'a', 'b');
end
fprintf('\n Data preparation complete!');

% Copying the compiled executable to the shared directory.
RunOnUnix(sprintf('rm -rf %s/shared', inputRoot));
RunOnUnix(sprintf('mkdir %s/shared', inputRoot));
RunOnUnix(sprintf('cp %s/%s %s/shared', compiledCodeRoot, compiledCodeName, inputRoot));

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
RunOnUnix(sprintf('./mkdag --cmdtorun=%s --data=%s --dagdir=%sOutput --pattern=product.mat --parg=inputPair.mat --type=Matlab', compiledCodeName, compiledCodeName, compiledCodeName));

%% Submit condor jobs.
% Submitting the DAG.
cd(sprintf('%s', outputRoot));
RunOnUnix(sprintf('condor_submit_dag mydag.dag'));

%% Collecting the output.
productCondor = NaN(size(pairs, 1),1);
for i = 1:size(pairs, 1)
    outputFile = sprintf('%s/Job%d/product.mat', outputRoot, i);
    if(~wait_for_existence(outputFile, 'file', 60, 900))
        fprintf('\n Collecting output from Job%d', i);
        load(outputFile);
        productCondor(i) = p;
    end
end

%% Comparing local and condor computations.
plot(productLocal, 'r.');
hold on;
xlabel('Pair #');
ylabel('Product');
plot(productCondor, 'bO');
legend('Locally computed', 'Condor computed');
title(sprintf('Difference between executing locally and on condor: %f', sumabs(productLocal - productCondor)));
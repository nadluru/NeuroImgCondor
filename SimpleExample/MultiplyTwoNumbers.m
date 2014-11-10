%% Main matlab function that you want to run on condor.
function p = MultiplyTwoNumbers(inputPairFile)
load(inputPairFile)
p = a * b;
save('product.mat','p');
return

%% Compiling code. Execute on a submit node.
% chtc_mcc --mtargets=MultiplyTwoNumbers.m --mfiles=MultiplyTwoNumbers.m

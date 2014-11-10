%% Function to run cmd on unix after printing it on Matlab console.
function RunOnUnix(cmd)
fprintf('\n %s', cmd);
unix(cmd);
return
%function [T1, rho, alpha_map, beta_map] = fit_t1_alpha_beta_irss( happyFlag, ir_imgs, ss_imgs, alpha_ss, mask )
function [T1, rho, alpha_map, beta_map] = fit_t1_alpha_beta_irssCondor(inputParameters, sharedParameters)

% Loading the input data.
load(inputParameters); % ir_imgs, ss_imgs, mask
load(sharedParameters); % happyFlag, alpha_ss

idx = find( mask > 0 );

opts = optimset('fminsearch');
opts.Display = 'none';
opts.TolFun = 1e-21;
opts.TolX = 1e-21;

predict_opts.t1_min = 50;
predict_opts.t1_max = 5000;
predict_opts.res = 100;
predict_opts.num_iter = 2;

beta_init = 180;
% beta_init = 145;

T1 = zeros(happyFlag.rcxres,happyFlag.rcyres);
rho = zeros(happyFlag.rcxres,happyFlag.rcyres);
alpha_map = zeros(happyFlag.rcxres,happyFlag.rcyres);
beta_map = zeros(happyFlag.rcxres,happyFlag.rcyres);
fprintf('\n About to begin fitting...');
for pt = 1:numel(idx)
    
    if( mod( pt, floor(numel(idx)/20) ) == 0 )
        pd = 100 * pt / numel(idx);
        msg = sprintf('%03f percent done',pd);
        disp(msg);
    end
    
    [yy, xx] = ind2sub( size( mask ), idx(pt) );
    alpha = happyFlag.flip_ir;
    ir_data = squeeze( ir_imgs(yy,xx,:) );
    
    if( numel(alpha_ss) > 0 )
        ss_data = squeeze( ss_imgs(yy,xx,:) );
    else
        ss_data = [];
    end
    
    [t1_initial, rho_initial] = predict_t1_rho_newer( happyFlag, alpha, ir_data, predict_opts ); % SRK changed to "predict_t1_rho_newer" instead of "predict_t1_rho_new" on 07/21/2014 to handle prediction for low T1 values.
    
    if( (happyFlag.real==1) && (happyFlag.psir==1) )
        ir_data = real(ir_data);
    elseif(happyFlag.psir==1)
        ir_data = sign_data( ir_data );
    end
    
    [fit_vals, fval, exit_flag, output] = fminsearch( @(x)viprir_sigfit_alpha_beta_ss2(x,happyFlag,ir_data,ss_data,alpha_ss),[t1_initial rho_initial 1 beta_init],opts);
    
    T1(yy,xx) = fit_vals(1);
    rho(yy,xx) = fit_vals(2);
    alpha_map(yy,xx) = fit_vals(3);
    beta_map(yy,xx) = fit_vals(4);
end
% Saving the output data.
save('T1RhoAlphaMapBetaMap.mat','T1', 'rho', 'alpha_map', 'beta_map') ;
return
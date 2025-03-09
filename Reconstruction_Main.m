%--------------------------------------------------------------------------
%Author: TaoLiu
%Date: 24/2/2023
%Note: This is the main function of the paper "Scanning phase imaging without
%stable illumination and scan position information"
%--------------------------------------------------------------------------
clear all;
for it         = 1:1
    %%
    %-------------------------------------
    %Parameters definition
%     clear all;
    p.it = it;
    addpath('Support Functions');
    addpath('Data Base');
    rng('shuffle');
    %------------------------------------
    %experiment setting
    p. binning                                     = 1;
    p. sz_fft                                      = 1024./p.binning;
    %units are mm
    p. lambda                                      = Ev2mm(8000);
    uncertain_position                             = (rand()-0.5)*2.3675*0.3;%0.3 represent the random position error is 15% of the correct value on one direction
    p. dis_obj2modu                                = 2.3675; %or 2.3675 + uncertain_position;
    p. dis_modu2ccd                                = 3500-p. dis_obj2modu;
    p. dis_obj2focus                               = 1;
    p. dx_dp                                       = 75e-3.*p.binning;
    p. dx_obj                                      = p. lambda.*p.dis_modu2ccd./p.sz_fft./p.dx_dp*1;
    p. dx_modu                                     = p. lambda.*p.dis_modu2ccd./p.sz_fft./p.dx_dp*1;
    %change the propagation method if the amount of sampling interval changes too much
    %------------------------------------- 
    %reconstruction setting
    p. recon_iter                                  = 1000;
    p. upsampling                                  = 1;
    p. show_results_every                          = 250;
    p. probe_update_after                          = 1;
    p. object_update_after                         = 0;
    p. offset_object                               = 100;%px
    p. modu_update_after                           = 0;
    p. pos_refine_after                            = 9999;
    p. pos_beta_update_method                      = 'T';% [T / Z] %different rules to update pos feedback coefficient
    p. pos_feeback_coeffient                       = 100;
    p. alpha_modu                                  = 0.9;
    p. algswitch                                   = AlgSeqGen(p. recon_iter,'HIO-type' ,99999, 10,5, p. recon_iter-30);
    p. sz_support                                  = 1.8e-3;%valid for serial reconstruction
    p. shift_support                               = [-4, -12];
    p. deconv_method                               = "none"; %[none]
    p. deconv_iter                                 = [0,0];%the first number is the period of update kernel, the second is iterations in each update
    %-------------------------------------
    %assemble object position setting
    p. known_pos                                   = false; %false = parallel, true = serial reconstruction
    p. assemble_iter                               = 150; %valid when position is unknown
    p. assemble_seq                                = 'linear'; %[random / linear]
    p. obj_update_method                           = 'ePIE';% [ePIE / PIE]
    p. probe_update_method                         = 'AVG';% [ePIE / PIE /  AVG ] %for parallel reconstruction use AVG
    p. alpha_object                                = 1;%for ePIE and PIE
    p. alpha_probe                                 = 0.9;%for ePIE and PIE
    p. method_gen_probe                            = 'load';% [load / support /dp_avg_ifft / ones] %method of probe generation
    p. probe_name                                  = 'probe_guess';% only valid for load probe method
    p. trans_precision                             = 5;
    %-------------------------------------
    %the coordinate setting is valid when position is known
    p. xy_inverse                                  = true;%false
    p. x_inverse                                   = false;%true
    p. y_inverse                                   = false;%true
    %-------------------------------------
    %diffraction pattern setting
    p. data_source                                 = 'nanoMAX';%[nanoMAX / I13]
    local_dir                                      = (pwd);
    p. data_location                               = strcat(local_dir , '\Data');
    p. data_num                                    = 31;%nanoMAX data
    p. num_dp_used                                 = 100;%["all" xx]; specify the number of dp used
    p. dp_trust_region                             = [1e-18,1e10];
    %bounds are included
    %-------------------------------------
    % modulator setting if applicable
    p. modu_update_method                          = 'PIE';%['AVG',PIE]
    p. modulator_name                              = 'mask15245x';
    p. method_gen_modulator                        = 'ones';%[load / ones / dps_avg]% initial guess
    %-------------------------------------
    %prepare cache
    cache_cpu                                      = PrepareDP(p);
    cache_cpu. modulator_guess                     = GnerateModulator(cache_cpu, p);
    device                                         = gpuDevice;
    reset(device);
    [p,cache_cpu,cache_gpu]                        = PrepareCache(p,cache_cpu);
    %-------------------------------------
    %%
    %reconstruction process
    %--------------------------------------------------------------------------
    if p. known_pos                                == false
        %-------------------------------------
        %Parallel mode
        [p,cache_cpu,cache_gpu]                    = ParallelReconstruction(p, cache_cpu , cache_gpu);
        %-------------------------------------
    else
        %-------------------------------------
        %Serial mode
        [p,cache_cpu,cache_gpu]                    = SerialReconstruction(p, cache_cpu , cache_gpu);
        %-------------------------------------
    end
%% for the uncetain position
% correct position can be estimated by adjusting the position for several
% times
% design map or STEM image shown in the paper can be used as reference
%[wf_out, dx] = focus(gather(cache_gpu.modulator_guess), p.dx_obj, -(0), 0.05,p.lambda, 'AS');
%
end

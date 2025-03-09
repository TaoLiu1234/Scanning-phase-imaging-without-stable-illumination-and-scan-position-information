%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [p,cache_cpu,cache_gpu]                              = PrepareCache(p,cache_cpu)
    fprintf("start cache process \n");
    if p. known_pos                                           == false
        %parallel mode
        var_size                                              = size(cache_cpu. dps_amp);
        var_size(1)                                           = var_size(1).*p.upsampling;
        var_size(2)                                           = var_size(2).*p.upsampling;
        %-------------------------------------
        %position feedback coefficient
        cache_gpu. pos_feeback_coeffient_y                    = gpuArray.ones( [1,var_size(3)] ,'double').*p.pos_feeback_coeffient;
        cache_gpu. pos_feeback_coeffient_x                    = gpuArray.ones( [1,var_size(3)] ,'double').*p.pos_feeback_coeffient;
        cache_gpu. last_sx                                    = gpuArray.ones([1,var_size(3)] ,'double');
        cache_gpu. last_sy                                    = gpuArray.ones([1,var_size(3)] ,'double');
        cache_gpu. object_guess                               = gpuArray.ones(var_size,'single');
    else
        %-------------------------------------
        %series mode
        var_size                                              = size(cache_cpu. modulator_guess);
        cache_gpu                                             = GeneratePos(p,[]);
        cache_gpu. pos_px_old                                 = cache_gpu.pos_px;
        max_y_px                                              = max(max(cache_gpu.pos_px.shifty));
        max_x_px                                              = max(max(cache_gpu.pos_px.shiftx));
        max_xy                                                = max(max_x_px,max_y_px);
        %-------------------------------------
        %define object
        cache_gpu. pos_px_old                                 = cache_gpu.pos_px;
        cache_gpu. object_guess_whole                         = gpuArray.ones(round( max_xy + p.sz_fft + p. offset_object).*p.upsampling,'single');
        %-------------------------------------
        %position feedback coefficient
        cache_gpu. pos_feeback_coeffient_y                    = gpuArray.ones( size(cache_gpu.pos_px.shifty) ,'double').*p.pos_feeback_coeffient;
        cache_gpu. pos_feeback_coeffient_x                    = gpuArray.ones( size(cache_gpu.pos_px.shiftx) ,'double').*p.pos_feeback_coeffient;
        cache_gpu. last_sx                                    = gpuArray.ones( size(cache_gpu.pos_px.shiftx) ,'double');
        cache_gpu. last_sy                                    = gpuArray.ones( size(cache_gpu.pos_px.shifty) ,'double');
        cache_gpu. sx                                         = gpuArray.ones( size(cache_gpu.pos_px.shiftx) ,'double');
        cache_gpu. sy                                         = gpuArray.ones( size(cache_gpu.pos_px.shifty) ,'double');
    end
    cache_gpu. conv_kernel                                    = abs(fft2(gpuArray.ones(p.sz_fft.*p.upsampling,'double')))./(p.sz_fft.*p.upsampling).^2;
    %-------------------------------------
    %cache for probe and support(may be abandoned future)
    cache_gpu. support                                        = GenerateSupport(p);
    cache_gpu. probe_guess                                    = GenerateProbe(p, cache_cpu, cache_gpu);
    %-------------------------------------
    %cache for wf_exit
    cache_gpu. wf_exit                                        = gpuArray.ones(var_size,'single');
    cache_gpu. wf_exit_old                                    = gpuArray.ones(var_size,'single');
    %-------------------------------------
    %cache for AS propagation between object and modulator
    [cache_gpu. chirp_forward, cache_gpu. chirp_backward]     = ChirpAS(p,p.dis_obj2modu);
    %-------------------------------------
    %cache for modulation
    cache_gpu. modulator_guess                                = gpuArray(single(cache_cpu. modulator_guess));
    cache_gpu. inty_modu                                      = cache_gpu. modulator_guess.*conj(cache_gpu. modulator_guess);
    cache_gpu. alpha_max_inty_modu                            = p. alpha_modu/max(max(cache_gpu. inty_modu));
    %-------------------------------------
    %cache for wf_modu_front wf_modu_rear
    cache_gpu. wf_modu_front                                  = gpuArray.ones(var_size,'single');
    cache_gpu. wf_modu_rear                                   = gpuArray.ones(var_size,'single');
    cache_gpu. wf_modu_rear_old                               = gpuArray.ones(var_size,'single');
    cache_gpu. wf_modu_rear_new                               = gpuArray.ones(var_size,'single');
    %-------------------------------------
    %cache for modulus constraint
    cache_gpu. wf_ccd_front                                   = gpuArray.ones(var_size,'single');
    cache_gpu. wf_ccd_rear                                    = gpuArray.ones(var_size,'single');
    cache_gpu. cal_dps_amp                                    = gpuArray.ones(var_size,'single');
    cache_gpu. dps_amp                                        = gpuArray(single(cache_cpu. dps_amp));
    cache_gpu. num_dps                                        = size(cache_gpu.dps_amp,3);

    cache_gpu. update_region                                  = gpuArray(single(cache_cpu. update_region));
    cache_gpu. update_region                                  = sum(cache_gpu.update_region,3);
    cache_gpu. update_region(find(cache_gpu.update_region     == cache_gpu. num_dps)) = 1;
    cache_gpu. update_region(find(cache_gpu.update_region     ~= 1))                  = 0;
    %-------------------------------------
    %other stuffs
    cache_cpu. random_seq                                     = randperm(cache_gpu.num_dps);
    cache_cpu. Fig_handels                                    = Display('Initiate',cache_gpu.probe_guess(:,:,1), ones(p.sz_fft),cache_gpu.modulator_guess(:,:,1), 0, p. recon_iter);
    %-------------------------------------
    fprintf("cache process finished \n");
end

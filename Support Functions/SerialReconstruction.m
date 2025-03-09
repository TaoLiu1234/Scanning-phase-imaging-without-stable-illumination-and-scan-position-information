%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 7/3/2023
%--------------------------------------------------------------------------
function [p, cache_cpu , cache_gpu]             = SerialReconstruction(p, cache_cpu , cache_gpu)
%--------------------------------------------------------------------------
%serial reconstruction
tic;
fprintf('Serial reconstruction \n');
for it                                          = 1:p. recon_iter
    for it2                                     = 1:cache_gpu.num_dps
        if p.assemble_seq                       == 'linear'
            index_dp                            = it2;
        else
            index_dp                            = cache_cpu. random_seq(it2);
        end
        %-------------------------------------
        %crop object
        int_shifty                              = round(cache_gpu. pos_px. shifty(index_dp));
        int_shiftx                              = round(cache_gpu. pos_px. shiftx(index_dp));
        frac_shifty                             = cache_gpu. pos_px. shifty(index_dp) - int_shifty;
        frac_shiftx                             = cache_gpu. pos_px. shiftx(index_dp) - int_shiftx;
        obj_shifty_min                          = int_shifty;
        obj_shifty_max                          = obj_shifty_min + p.sz_fft.*p.upsampling -1;
        obj_shiftx_min                          = int_shiftx;
        obj_shiftx_max                          = obj_shiftx_min + p.sz_fft.*p.upsampling -1;
        %-------------------------------------
        part_object                             = CircshiftFFT(cache_gpu.object_guess_whole(obj_shifty_min : obj_shifty_max , obj_shiftx_min : obj_shiftx_max),-[frac_shifty, frac_shiftx]);
        %-------------------------
        cache_gpu.wf_exit_old                   = cache_gpu. probe_guess.*part_object;
        %-------------------------------------
        %forward propagate to the modulator plane
        cache_gpu.wf_modu_front                 = AngularSpectrumPropagation(cache_gpu. wf_exit_old , cache_gpu. chirp_forward);
        %-------------------------------------
        %apply modulation
        cache_gpu.wf_modu_rear_old              = cache_gpu. wf_modu_rear;
        cache_gpu.wf_modu_rear                  = Modulation(cache_gpu. wf_modu_front ,cache_gpu. modulator_guess);
        %-------------------------------------
        %switch algorithm
        if p. algswitch(it)                     == 0
            cache_gpu.wf_modu_rear_old          = cache_gpu. wf_modu_rear;
        end
        cache_gpu.wf_modu_rear_new              = 2*cache_gpu. wf_modu_rear - cache_gpu. wf_modu_rear_old;
        %-------------------------------------
        %propagate to the ccd plane
        cache_gpu.wf_ccd_front                  = FraunhoferPropagation_forward(cache_gpu. wf_modu_rear_new , p. sz_fft,1);
        %------------------------------------- 
        %deconvolution to get cal_dps_amp
        [cache_gpu. cal_dps_amp,cache_gpu.conv_kernel] = CalculateDpsAmp(cache_gpu.wf_ccd_front,cache_gpu. cal_dps_amp, cache_gpu.conv_kernel,cache_gpu.dps_amp(:,:,index_dp),p.deconv_method, p. deconv_iter, it, p.upsampling ,p.sz_fft ,1);
        %-------------------------------------
        %apply modulus constraint  
        cache_gpu.wf_ccd_rear                   = ModulusConstraint(cache_gpu. wf_ccd_front,cache_gpu. cal_dps_amp, cache_gpu. dps_amp(:,:,index_dp),p.sz_fft,p.upsampling, 1 , cache_gpu. update_region);
        %-------------------------------------
        %back propagate to the modulator plane
        cache_gpu.wf_modu_rear_new              = FraunhoferPropagation_backward(cache_gpu.wf_ccd_rear, p. sz_fft,1);        
        %-------------------------------------
        %switch algorithm
        cache_gpu.wf_modu_rear                  = cache_gpu.wf_modu_rear_new + cache_gpu.wf_modu_rear_old - cache_gpu.wf_modu_rear;
        %-------------------------------------
        %update modulator
        if it                                   > p.modu_update_after
            cache_gpu.modulator_guess           = UpdateModulator( cache_gpu.wf_modu_front, cache_gpu.wf_modu_rear_new, cache_gpu. modulator_guess, p.modu_update_method, p. alpha_modu);
        end
        %-------------------------------------
        %undo modulation
        cache_gpu.wf_modu_front                 = UndoModulation(cache_gpu. wf_modu_front, cache_gpu. modulator_guess, cache_gpu. wf_modu_rear, cache_gpu. inty_modu, cache_gpu. alpha_max_inty_modu, p. alpha_modu);
        %-------------------------------------
        %propagate to the support plane
        cache_gpu.wf_exit                       = AngularSpectrumPropagation(cache_gpu. wf_modu_front,cache_gpu. chirp_backward);
        %-------------------------------------
        %update object
        if it                                   > p. object_update_after
            revised_part_object                 = UpdateFunction(p.obj_update_method, part_object, cache_gpu.probe_guess,cache_gpu.wf_exit, cache_gpu.wf_exit_old, p.alpha_object);
            cache_gpu.object_guess_whole(obj_shifty_min : obj_shifty_max , obj_shiftx_min : obj_shiftx_max) = CircshiftFFT(revised_part_object,[frac_shifty, frac_shiftx]);
        end
        %-------------------------------------
        %update probe
        if it                                   > p. probe_update_after
            cache_gpu.probe_guess               = UpdateFunction(p.probe_update_method, cache_gpu.probe_guess, part_object, cache_gpu.wf_exit, cache_gpu.wf_exit_old, p.alpha_probe);
        end
        %-------------------------------------   
        %position index
        if it                                   > p. pos_refine_after
            [cache_gpu.sy(index_dp),cache_gpu.sx(index_dp)] = ShiftSearch(p, (abs(revised_part_object)), (abs(part_object)), true,0);
            %-------------------------------------
            if p.pos_beta_update_method         == "T"
                cache_gpu                       = BetaUpdate(p.pos_beta_update_method,cache_gpu,index_dp);
            end
        end
    end
    if it                                       > p. pos_refine_after
        if p.pos_beta_update_method             == "Z"
            cache_gpu                           = BetaUpdate(p.pos_beta_update_method,cache_gpu,index_dp);
        end
    end
    %-------------------------------------
    %display results
    if mod(it,p. show_results_every)            ==0
        ProgressBar(it,p. recon_iter,10,mean(cache_gpu.pos_feeback_coeffient_x),mean(cache_gpu.pos_feeback_coeffient_y), p.show_results_every);
        cache_cpu.Fig_handels                   = Display('Update',cache_gpu.probe_guess, cache_gpu.object_guess_whole, cache_gpu.modulator_guess(:,:,1), it, p. recon_iter, cache_cpu.Fig_handels);
    end
    %-------------------------------------
end
fprintf("serial reconstruction finished! \n");
toc;
end


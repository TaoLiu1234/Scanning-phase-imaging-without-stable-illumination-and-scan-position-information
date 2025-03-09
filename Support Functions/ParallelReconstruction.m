%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [p, cache_cpu , cache_gpu]  = ParallelReconstruction(p, cache_cpu, cache_gpu)
fprintf("start parallel reconstruction \n");
%--------------------------------------------------------------------------
%parallel reconstruction
tic;
for it                               = 1: p. recon_iter
    %-------------------------------------
    %calculate exit wave
    cache_gpu.wf_exit_old            = cache_gpu.probe_guess.*cache_gpu.object_guess;
    %-------------------------------------
    %forward propagate to the modulator plane
    cache_gpu.wf_modu_front          = AngularSpectrumPropagation(cache_gpu. wf_exit_old , cache_gpu. chirp_forward);
    %-------------------------------------
    %apply modulation
    cache_gpu.wf_modu_rear_old       = cache_gpu. wf_modu_rear;
    cache_gpu.wf_modu_rear           = Modulation(cache_gpu. wf_modu_front ,cache_gpu. modulator_guess);
    %-------------------------------------
    %switch algorithm
    if p. algswitch(it)              == 0
        cache_gpu.wf_modu_rear_old   = cache_gpu. wf_modu_rear;
    end
    cache_gpu.wf_modu_rear_new       = 2*cache_gpu. wf_modu_rear - cache_gpu. wf_modu_rear_old;
    %-------------------------------------
    %propagate to the ccd plane
    cache_gpu.wf_ccd_front           = FraunhoferPropagation_forward(cache_gpu. wf_modu_rear_new , p. sz_fft.*p.upsampling,cache_gpu. num_dps);
    %-------------------------------------
    %deconvolution to get cal_dps_amp
    [cache_gpu. cal_dps_amp,cache_gpu.conv_kernel] = CalculateDpsAmp(cache_gpu.wf_ccd_front,cache_gpu. cal_dps_amp, cache_gpu.conv_kernel,cache_gpu.dps_amp,p.deconv_method, p. deconv_iter, it, p.upsampling ,p.sz_fft ,cache_gpu. num_dps);
    %-------------------------------------
    %apply modulus constraint  
    cache_gpu.wf_ccd_rear            = ModulusConstraint(cache_gpu. wf_ccd_front, cache_gpu.cal_dps_amp, cache_gpu. dps_amp,p.sz_fft,p.upsampling,cache_gpu. num_dps, cache_gpu. update_region);
    %-------------------------------------
    %back propagate to the modulator plane
    cache_gpu.wf_modu_rear_new       = FraunhoferPropagation_backward(cache_gpu.wf_ccd_rear, p. sz_fft.*p.upsampling,cache_gpu. num_dps);
    %-------------------------------------
    %update modulator
    if it                            > p.modu_update_after
        cache_gpu.modulator_guess    = UpdateModulator( cache_gpu.wf_modu_front, cache_gpu.wf_modu_rear_new, cache_gpu. modulator_guess, p.modu_update_method, p. alpha_modu );
    end
    %-------------------------------------
    %switch algorithm
    cache_gpu.wf_modu_rear           = cache_gpu.wf_modu_rear_new + cache_gpu.wf_modu_rear_old - cache_gpu.wf_modu_rear;
    %-------------------------------------
    %undo modulation
    cache_gpu.wf_modu_front          = UndoModulation(cache_gpu. wf_modu_front, cache_gpu. modulator_guess, cache_gpu. wf_modu_rear, cache_gpu. inty_modu, cache_gpu. alpha_max_inty_modu, p. alpha_modu);
    %-------------------------------------
    %propagate to the support plane
    cache_gpu.wf_exit                = AngularSpectrumPropagation(cache_gpu.wf_modu_front,cache_gpu. chirp_backward);
    %-------------------------------------
    %splite probe from reconstructed wavefront
    %-------------------------------------
    %update probe
    if it                            > p. probe_update_after
        cache_gpu. probe_guess   = UpdateFunction(p.probe_update_method, cache_gpu. probe_guess, cache_gpu.object_guess, cache_gpu.wf_exit, cache_gpu.wf_exit_old, p.alpha_probe);
    end
    %update object
    if it                            > p. object_update_after
        cache_gpu.object_guess       = UpdateFunction(p.obj_update_method, cache_gpu.object_guess, cache_gpu.probe_guess, cache_gpu.wf_exit, cache_gpu.wf_exit_old, p.alpha_object);
    end

    %-------------------------------------
    %show results
    if mod(it,p. show_results_every) ==0
        ProgressBar(it, p. recon_iter,10,0,0, p.show_results_every);
        cache_cpu.Fig_handels        = Display('Update',cache_gpu.probe_guess, cache_gpu.object_guess(:,:,1),cache_gpu.modulator_guess(:,:,1), it, p. recon_iter, cache_cpu.Fig_handels);
    end 
    %-------------------------------------
end
fprintf("parallel reconstruction finished! \n");
toc;
%--------------------------------------------------------------------------
%% position index
% cache_gpu                            = GeneratePos(p, cache_gpu);
% fprintf("position founded \n");
%--------------------------------------------------------------------------
%% assemble object
% [p, cache_cpu , cache_gpu]           = AssembleObject(p, cache_cpu , cache_gpu);
% fprintf("assemble finished \n");
%--------------------------------------------------------------------------
end
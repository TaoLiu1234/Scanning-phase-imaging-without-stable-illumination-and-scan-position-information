%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 27/2/2023
%--------------------------------------------------------------------------

function [p,cache_cpu,cache_gpu]                      = AssembleObject(p,cache_cpu,cache_gpu)
    %-------------------------------------
    %initilization
    max_y_px                                          = max(max(cache_gpu.pos_px.shifty));
    max_x_px                                          = max(max(cache_gpu.pos_px.shiftx));
    max_xy                                            = max(max_x_px,max_y_px);
    
    cache_gpu.pos_px_old                              = cache_gpu.pos_px;
    cache_gpu. object_guess_whole                     = gpuArray.ones(round( max_xy + p.sz_fft + p. offset_object).*p.upsampling,'single');

    for it                                            = 1:p.assemble_iter
        if strcmp(p. obj_update_method , 'PIE')       || strcmp(p. obj_update_method , 'ePIE')
            for it2                                   = 1:cache_gpu.num_dps
                if p.assemble_seq                     == 'linear'
                    index_dp                          = it2;
                else
                    index_dp                          = cache_cpu. random_seq(it2);
                end
                %-------------------------------------
                %get int shift and frac shift
                int_shifty                            = round(cache_gpu. pos_px. shifty(index_dp));
                int_shiftx                            = round(cache_gpu. pos_px. shiftx(index_dp));
                frac_shifty                           = cache_gpu. pos_px. shifty(index_dp) - int_shifty;
                frac_shiftx                           = cache_gpu. pos_px. shiftx(index_dp) - int_shiftx;
                obj_shifty_min                        = int_shifty;
                obj_shifty_max                        = obj_shifty_min + p.sz_fft.*p.upsampling -1;
                obj_shiftx_min                        = int_shiftx;
                obj_shiftx_max                        = obj_shiftx_min + p.sz_fft.*p.upsampling -1;
                %-------------------------------------
                %shift
                part_object                           = CircshiftFFT(cache_gpu. object_guess_whole( obj_shifty_min : obj_shifty_max , obj_shiftx_min : obj_shiftx_max), -[frac_shifty, frac_shiftx]);
                wavefront                             = cache_gpu. probe_guess.*part_object;
                %-------------------------------------
                %update object
                if it                                 > p. object_update_after
                    revised_part_object               = UpdateFunction(p.obj_update_method, part_object, cache_gpu.probe_guess, cache_gpu.wf_exit(:,:,index_dp), wavefront , p.alpha_object);
                    cache_gpu. object_guess_whole(obj_shifty_min : obj_shifty_max , obj_shiftx_min : obj_shiftx_max) = CircshiftFFT(revised_part_object,[frac_shifty, frac_shiftx]);
                end
                %update probe
                if it                                 > p. probe_update_after
                    cache_gpu. probe_guess            = UpdateFunction(p.obj_update_method, cache_gpu. probe_guess, part_object, cache_gpu.wf_exit(:,:,index_dp), wavefront, p.alpha_probe);
                end
                %-------------------------------------
                %position refinement
                if it                                 > p. pos_refine_after
                    [cache_gpu.sy(index_dp),cache_gpu.sx(index_dp)] = ShiftSearch(p, revised_part_object, part_object, false,0);
                    if p.pos_beta_update_method       == "T"
                        cache_gpu                     = BetaUpdate(p.pos_beta_update_method,cache_gpu,index_dp);
                    end
                end
                %-------------------------------------
            end
            if it                                     > p. pos_refine_after
                if p.pos_beta_update_method           == "Z"
                    cache_gpu                         = BetaUpdate(p.pos_beta_update_method,cache_gpu,index_dp);
                end
            end
            %-------------------------------------
            if mod(it,p. show_results_every)          ==0
                ProgressBar(it, p. assemble_iter,10,mean(cache_gpu.pos_feeback_coeffient_x),mean(cache_gpu.pos_feeback_coeffient_y), p.show_results_every);
                cache_cpu.Fig_handels                 = Display('Update',cache_gpu.probe_guess, cache_gpu.object_guess_whole, cache_gpu.modulator_guess(:,:,1), it, p. recon_iter, cache_cpu.Fig_handels);
            end
            %-------------------------------------
        elseif p. assemble_method                     == "Serial"
            %-------------
            %precondition
            %-------------
            [p, cache_cpu , cache_gpu]                = SerialReconstruction(p, cache_cpu , cache_gpu);
        end
    end


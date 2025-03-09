%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 4/5/2023
%--------------------------------------------------------------------------
function [cache_gpu]                              = SpliteWavefront(p, cache_gpu)
    
    for it                                        = 1: p. seperate_iter
        %-------------------------------------
        %update probe
        cache_gpu. probe_guess                    = cache_gpu.probe_guess + 1.*conj(mean(cache_gpu.object_guess,3))./max(max(abs(conj(mean(cache_gpu.object_guess,3))).^2)).*(mean(cache_gpu.wf_exit - cache_gpu.probe_guess.*cache_gpu.object_guess,3));
        %-------------------------------------
        %update object
        for index_dp                              = 1: cache_gpu. num_dps
            cache_gpu. object_guess(:,:,index_dp) = cache_gpu.object_guess(:,:,index_dp) + 1.*conj(cache_gpu.probe_guess)./max(max(abs(conj(cache_gpu.probe_guess)).^2)).*(cache_gpu.wf_exit(:,:,index_dp) - cache_gpu.probe_guess.*cache_gpu.object_guess(:,:,index_dp));
        end
        %-------------------------------------
    end
end


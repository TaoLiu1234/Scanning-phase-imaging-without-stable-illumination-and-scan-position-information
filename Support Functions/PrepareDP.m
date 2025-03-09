%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 24/2/2023
%--------------------------------------------------------------------------

function [cache_cpu]                                           = PrepareDP(p)
%%
%-------------------------------------
%Precondition for diffraction pattern
switch p. data_source
    case 'nanoMAX'
        load([p. data_location '/raw_dps_s' num2str(p. data_num,'%06d')]);
    case 'I13'
        load([p. data_location '\dpx.mat']);
        dps = dpx;
end

if num2str(p. num_dp_used)                                     ~= "all"
    dps                                                        = dps(:,:,(1:p.num_dp_used));
end
cache_cpu. sz_dps                                              = size(dps);
temp_dps_amp                                                   = ones(p.sz_fft,p.sz_fft,cache_cpu.sz_dps(3));
temp_update_region                                             = ones(p.sz_fft,p.sz_fft,cache_cpu.sz_dps(3));

for it                                                         = 1:size(dps,3)
    temp_dp                                                    = dps(:,:,it);
    if p.binning>1
        dp                                                     = circshift(CutoutCenter(temp_dp(floor(p.binning/2)+1:p.binning:end, floor(p.binning/2)+1:p.binning:end),p. sz_fft),[0 0]);
    else
        dp                                                     = circshift(CutoutCenter(temp_dp,p. sz_fft),[0 0]);
    end
    
    %-----------------------------------%

    if p. data_source == "I13"
        temp_dps_amp(:,:,it)                                   = fftshift(abs(dp))+eps;
        %-----------------------------------%
        temp                                                   = temp_update_region(:,:,it);
        temp(find(angle(dp)>3))    = 0;
        temp_update_region(:,:,it)                             = fftshift(temp);
    else
        temp_dps_amp(:,:,it)                                   = fftshift(sqrt(dp))+eps;
        %-----------------------------------%
        temp                                                   = temp_update_region(:,:,it);
        temp(find(log(sqrt(dp)^2+1)<p. dp_trust_region(1)))    = 0;
        temp(find(dp>p. dp_trust_region(2)))                   = 0;
        temp_update_region(:,:,it)                             = fftshift(temp);
    end
end
cache_cpu. dps_amp                                             = temp_dps_amp;
cache_cpu. update_region                                       = temp_update_region(:,:,1);
cache_cpu. dp_avg                                              = mean(dps,3);
cache_cpu. dp_avg_energy                                       = sum(sum(cache_cpu. dp_avg));
end

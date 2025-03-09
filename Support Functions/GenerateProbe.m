%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 28/2/2023
%--------------------------------------------------------------------------

function [probe]                             = GenerateProbe(p,cache_cpu,cache_gpu)
    %-------------------------------------
    switch p. method_gen_probe
        case 'load'
            load(p. probe_name);
            probe                            = gather( eval(p. probe_name) );
        case 'support'
            probe                            = cache_gpu.support;
        case 'ones'
            probe                            = gpuArray.ones(p.sz_fft,'single');
        case 'dp_avg_ifft'
            temp                             = sqrt(cache_cpu.dp_avg);
            max_temp                         = max(max(temp));
            temp(temp<max_temp*0.1)          = 0; 
            if cache_cpu.sz_dps(1)           < p.sz_fft

                temp                         = PadOutCenter(temp,p.sz_fft.*p.upsampling,1);
            else
                temp                         = CutoutCenter(temp,p.sz_fft.*p.upsampling);
            end
            probe                            = gpuArray(single(ifftshift(ifft2(ifftshift(temp)))));
            [temp_charp_for,temp_charp_back] = ChirpAS(p,p. dis_obj2focus);
            probe                            = gpuArray(single(PadOutCenter(probe,p.sz_fft.*p.upsampling,0)));
            probe                            = AngularSpectrumPropagation(probe,temp_charp_for);
            
    end
    probe                                    = gpuArray(single(PadOutCenter(probe,p.sz_fft.*p.upsampling,0)));
    %-------------------------------------
    %energy distributed
    probe_energy                             = sum(sum(abs(probe).^2));
    amp_correct_factor                       = sqrt(cache_cpu.dp_avg_energy/probe_energy);
    probe                                    = probe.*amp_correct_factor;
end

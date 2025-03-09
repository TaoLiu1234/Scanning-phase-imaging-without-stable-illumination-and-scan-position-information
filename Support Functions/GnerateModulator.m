%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [modulator]                              = GnerateModulator(cache_cpu, p)
    switch p. method_gen_modulator
        case 'load'
            load([p.modulator_name '.mat']);
            modulator                             = gather( eval(p.modulator_name));
        case 'ones'
            modulator                             = ones(p.sz_fft);
        case 'dps_avg'
            modulator                             = (ifftshift(ifft2(fftshift(sqrt(cache_cpu.dp_avg)))));
            [temp_charp_for,temp_charp_back]      = ChirpAS(p,p. dis_obj2focus);
            modulator                             = abs(AngularSpectrumPropagation(modulator,temp_charp_for));
    end
    modulator                                     = PadOutCenter(modulator,p.sz_fft.*p.upsampling,1);
    
end


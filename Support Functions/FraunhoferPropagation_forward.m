%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [propagated_wavefront]     = FraunhoferPropagation_forward(wavefront,sz_fft,num)
    propagated_wavefront            = fftshift(fft2(wavefront),3)./sz_fft;
end

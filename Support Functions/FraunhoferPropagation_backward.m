%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [propagated_wavefront]     = FraunhoferPropagation_backward(wavefront ,sz_fft,num)
     propagated_wavefront           = ifft2((wavefront)).*sz_fft;
end

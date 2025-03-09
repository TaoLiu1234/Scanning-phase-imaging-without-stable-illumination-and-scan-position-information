%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [wavefront_rear]     = AngularSpectrumPropagation(wavefront_front, chirp)
   wavefront_rear             = ifft2(fft2(wavefront_front).*chirp);
end


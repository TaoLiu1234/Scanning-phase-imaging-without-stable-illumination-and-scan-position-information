%--------------------------------------------------------------------------
%Author: Tao Liu, Fucai Zhang 
%Date: 23/5/2023, 15/06/2015
%--------------------------------------------------------------------------

function [Chirp_forward,Chirp_backward] = ChirpAS(p,z)
px                                      = p. dx_obj;
M                                       = p. sz_fft.*p. upsampling;
m2                                      = ceil(M/2);

u                                       = [0:m2-1 m2-M:-1]/M/px*p. lambda;
[fx,fy]                                 = meshgrid(u,u);
Chirp_forward                           = gpuArray(single( exp(2i*pi*z*sqrt(1-fx.^2-fy.^2)./p. lambda)));
Chirp_backward                          = gpuArray(single( conj(Chirp_forward)));

end
%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 15/06/2015
%Note: usage: im_shifted = circshiftft(im, [sy sx])
% same as circshift in Matlab
% Shift an image by arbitrary value, e.g. pi
%--------------------------------------------------------------------------

function  shift_img  = CircshiftFFT(img, shift)

[M,N]                = size(img);

x                    = [0:floor(N/2), -ceil(N/2)+1:-1];
y                    = [0:floor(M/2), -ceil(M/2)+1:-1].';

x                    = exp(-2i*pi*x*shift(2)/N);
y                    = exp(-2i*pi*y*shift(1)/M);

H                    = y*x;
shift_img            = ifft2(H.*fft2(img));
end




%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 28/1/2015
%Note: if im1 is larger than im2 then its center region is cut out, otherwise
% im1 is returned intact. 
%--------------------------------------------------------------------------

function out  = CutoutCenter(im_1, im_2)

if isscalar(im_2)
    sz_2      = im_2;
else 
sz_2          = size(im_2);
end

sz_1          = size(im_1);

if any(sz_1 > sz_2)
    sz_fft    = min(sz_1,sz_2);
    offset    = fix(abs(sz_2 - sz_1)/2);
    ry        = offset(1) + (1:sz_fft(1));  % index of central range of big matrix: y
    rx        = offset(2) + (1:sz_fft(2));  % index of central range of big matrix: x
    out       = im_1(ry, rx);
else
    out       = im_1;
end

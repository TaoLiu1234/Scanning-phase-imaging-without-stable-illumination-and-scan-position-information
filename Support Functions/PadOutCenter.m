%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 16/4/2014
%--------------------------------------------------------------------------
function out        = PadOutCenter(im_1, sz, val)
% if im1 is larger than im2 then its centerl region is cut out, otherwise
% im1 is returned intact.
% support 3D 

if nargin<3, val    =0;  end
sz_1                = size(im_1);
out                 = val*ones(sz);
sz_fft              = min(sz_1,sz);
offset              = fix(abs(sz - sz_1)/2);
ry                  = offset(1)+(1:sz_fft(1));  % index of central range of big matrix: y
rx                  = offset(2)+(1:sz_fft(2));  % index of central range of big matrix: x
out(ry, rx)         = im_1;
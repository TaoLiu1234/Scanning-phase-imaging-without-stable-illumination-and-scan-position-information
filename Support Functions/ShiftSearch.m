%--------------------------------------------------------------------------
%Author: Taoliu, Fucai Zhang
%Date: 3/3/2023
%Note: shift from img1 to img2; triger is used to eliminate the influence of
%probe
%--------------------------------------------------------------------------

function [re_shifty,re_shiftx]      = ShiftSearch(p,img1,img2,triger,integer_skip)
    if triger == true
    %-------------------------------------
    %gradient calculation
        g1                          = ScalingGradient(img1);
        g2                          = ScalingGradient(img2);
    else
        g1                          = img1;
        g2                          = img2;
    end
    %-------------------------------------
    %calculate crossspectrum
    NUM_PASS                        = p.trans_precision;

    im1                             = double(g1);
    im2                             = double(g2);

    us                              = 30;
    cls                             = class(im1);

    window                          = 1.5*us;
    window                          = window + mod(window,2);
    window_center                   = fix(window/2);

    CS                              = fft2(im1).*conj(fft2(im2));
    shift                           = [0, 0];
    %-------------------------------------
    % find integer shift
    sz_im                           = size(im1);
    ny                              = sz_im(1);
    nx                              = sz_im(2);

    ny                              = ny*ones(cls);
    nx                              = nx*ones(cls);

    if ~integer_skip
        a                           = abs(ifft2((CS)));
        %-------------------------------------------------
        % filter center to eliminate wrong positoning due to the noise, the
        % value 10 should be estimated by looking at the peak position of
        % recovered exitwaves. generally 2~12 pixels 
%         temp = fftshift(a);
%         temp(sz_im/2-10:sz_im/2+10,sz_im/2-10:sz_im/2+10) = 0;
%         a = fftshift(temp);
        %-------------------------------------------------
        max_a                       = max(max(a));
        [iy,ix]                     = find(a == max_a);
        shift                       = [mean(iy),mean(ix)];
        shift                       = shift - double(shift > fix(sz_im/2)).*sz_im - 1;
    end
    %-------------------------------------
    % find fractional shift
    p                               = floor(nx/2);
    x                               = [p+1:nx 1:p].'-p -1;
    q                               = floor(ny/2);
    y                               = [q+1:ny 1:q]-q -1;

    zero                            = zeros(cls);
    winx                            = (zero:window(end)-1);
    winy                            = (zero:window(1)-1).';
    num_pass                        = 1;
    usfac                           = ones(cls);


    while num_pass                  < NUM_PASS
        usfac                       = usfac*us;
        shift                       = round(shift*usfac);
        offset                      = window_center - shift;

        argx                        = 2*pi/nx/usfac *x*(winx - offset(2));
        kernel_x                    = exp(1i*argx);
        argy                        = 2*pi/ny/usfac *(winy - offset(1))* y;
        kernel_y                    = exp(1i*argy);
        out                         = kernel_y*CS*kernel_x;
        aout                        = abs(out);
        max_out                     = max(max(aout));
        [ty,tx]                     = find(aout == max_out);
        shift_refine                = [mean(ty),mean(tx)];
        shift_refine                = shift_refine - window_center -1;
        shift                       = (shift + shift_refine)/usfac;
        num_pass                    = num_pass + 1;
    end
    %-------------------------------------

    re_shiftx                       = shift(2);
    re_shifty                       = shift(1);
    
end


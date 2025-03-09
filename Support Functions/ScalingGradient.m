%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2024
%--------------------------------------------------------------------------
function [gradient] = ScalingGradient(input_image)
    f_image         = fftshift(fft2(input_image))./length(input_image);
    cut_f_image     = imresize(f_image, [(length(input_image)-2),(length(input_image)-2)] ,"lanczos2");
    scaled_image    = PadOutCenter(ifft2(ifftshift(cut_f_image)).*(length(input_image)-2),length(input_image),0);
    gradient        = abs(scaled_image) - abs(input_image);
end


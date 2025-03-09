%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [wavefront_rear]           = ModulusConstraint(wavefront_front,cal_dps_amp,dps_amp,sz_fft,upsampling,num_layers,update_region)
    update                          = ( (dps_amp./(cal_dps_amp+eps)).*update_region + (1-update_region) );
    temp_update                     = gpuArray.ones([sz_fft.*upsampling,sz_fft.*upsampling,num_layers],'single');
    if upsampling                   ~= 1
        for layers                  = 1:num_layers
            temp_update(:,:,layers) = imresize(update(:,:,layers),[sz_fft.*upsampling, sz_fft.*upsampling],'nearest');
        end
        update                      = temp_update;
    end
    wavefront_rear                  = update.*wavefront_front;
end
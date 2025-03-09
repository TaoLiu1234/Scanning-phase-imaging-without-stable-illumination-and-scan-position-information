%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 27/2/2023
%--------------------------------------------------------------------------

function cache_gpu                          = GeneratePos(p,cache_gpu)

    if p. known_pos                         == false
        cache_gpu. pos_px. shifty           = gpuArray.zeros(cache_gpu. num_dps,1,'single');
        cache_gpu. pos_px. shiftx           = gpuArray.zeros(cache_gpu. num_dps,1,'single');
        for it                              = 1:(cache_gpu. num_dps - 1)
            %-------------------------------------
            %perform calcualtion for ROI
            [re_shifty,re_shiftx]           = ShiftSearch(p,(angle(cache_gpu. object_guess(:,:,it))).*cache_gpu.support, (angle(cache_gpu. object_guess(:,:,(it+1)))).*cache_gpu.support,false,0);
            %-------------------------------------
            %build position info
            cache_gpu. pos_px. shifty(it+1) = cache_gpu. pos_px. shifty(it) + re_shifty;
            cache_gpu. pos_px. shiftx(it+1) = cache_gpu. pos_px. shiftx(it) + re_shiftx;
            %-------------------------------------
        end
    else
        %-------------------------------------
        %load position info
        switch p.data_source
            case 'nanoMAX'
                load([p. data_location, '/xypos_', num2str(p. data_num,'%06d')]);
                pos_readout_x               = reshape(pos(1,:),[],1)* 1e-3;
                pos_readout_y               = reshape(pos(2,:),[],1)* 1e-3;
                pos_readout_x               = pos_readout_x - (min(pos_readout_x) + max(pos_readout_x))/2;
                pos_readout_y               = pos_readout_y - (min(pos_readout_y) + max(pos_readout_y))/2;
            case 'I13'
                pos_readout_x = ones(11,1);
                pos_readout_y = ones(11,1);
        end
        cache_gpu. pos_px. shifty           = gpuArray.zeros(1,length(pos_readout_y),'double');
        cache_gpu. pos_px. shiftx           = gpuArray.zeros(1,length(pos_readout_x),'double');
        pos_px_x                            = (pos_readout_x)./p. dx_obj;
        pos_px_y                            = (pos_readout_y)./p. dx_obj; 
        if p.xy_inverse                     == true
            temp                            = pos_px_x;
            pos_px_x                        = pos_px_y;
            pos_px_x                        = temp;
        end
        if p.x_inverse                      == true
            pos_px_x                        = -(pos_px_x);
        end
        if p.y_inverse                      == true
            pos_px_y                        = -(pos_px_y);
        end
        %-------------------------------------
        %specify the number of diffraction pattern useds
        if num2str(p. num_dp_used)          ~= "all"
            cache_gpu. pos_px. shifty       = pos_px_y(1:p. num_dp_used,1);
            cache_gpu. pos_px. shiftx       = pos_px_x(1:p. num_dp_used,1);
        else
            cache_gpu. pos_px. shifty       = pos_px_y;
            cache_gpu. pos_px. shiftx       = pos_px_x;            
        end
    end

    %-------------------------------------
    %make sure that all pos are positive
    min_x_px                                = min(min(cache_gpu.pos_px.shiftx));
    min_y_px                                = min(min(cache_gpu.pos_px.shifty));
    min_xy                                  = min(min_x_px,min_y_px);
    
    cache_gpu.pos_px.shiftx                 = cache_gpu.pos_px.shiftx - min_xy  + 10;
    cache_gpu.pos_px.shifty                 = cache_gpu.pos_px.shifty - min_xy  + 10;


end


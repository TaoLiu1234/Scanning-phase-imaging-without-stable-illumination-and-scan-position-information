%--------------------------------------------------------------------------
%Author: Tao Liu, Fucai Zhang
%Date: 23/5/2023
%--------------------------------------------------------------------------
function [cache_gpu]                                     = BetaUpdate(method,cache_gpu,index_dp)
    if method                                            == "T"
        if abs(cache_gpu.sy(index_dp))>1e-5 && cache_gpu.last_sy(index_dp)*cache_gpu.sy(index_dp) > 0 && abs(cache_gpu.last_sy(index_dp)) > abs(cache_gpu.sy(index_dp))
            cache_gpu. pos_feeback_coeffient_y(index_dp) = 1.1*cache_gpu. pos_feeback_coeffient_y(index_dp);
        elseif abs(cache_gpu.sy(index_dp))< 1e-5 || cache_gpu.sy(index_dp)*cache_gpu.last_sy(index_dp)<0
            cache_gpu. pos_feeback_coeffient_y(index_dp) = 0.8*cache_gpu. pos_feeback_coeffient_y(index_dp);
        end
        if abs(cache_gpu.sx(index_dp))>1e-5 && cache_gpu.last_sx(index_dp)*cache_gpu.sx(index_dp) > 0 && abs(cache_gpu.last_sx(index_dp)) > abs(cache_gpu.sx(index_dp))
            cache_gpu. pos_feeback_coeffient_x(index_dp) = 1.1*cache_gpu. pos_feeback_coeffient_x(index_dp);
        elseif abs(cache_gpu.sx(index_dp))< 1e-5 || cache_gpu.sx(index_dp)*cache_gpu.last_sx(index_dp)<0
            cache_gpu. pos_feeback_coeffient_x(index_dp) = 0.8*cache_gpu. pos_feeback_coeffient_x(index_dp);
        end

        cache_gpu.pos_px.shifty(index_dp)                = cache_gpu. pos_px. shifty(index_dp) - cache_gpu. pos_feeback_coeffient_y(index_dp)*cache_gpu.sy(index_dp);
        cache_gpu.pos_px.shiftx(index_dp)                = cache_gpu. pos_px. shiftx(index_dp) - cache_gpu. pos_feeback_coeffient_x(index_dp)*cache_gpu.sx(index_dp);

        cache_gpu.last_sx(index_dp)                      = cache_gpu.sx(index_dp);
        cache_gpu.last_sy(index_dp)                      = cache_gpu.sy(index_dp);
    else
        cache_gpu.pos_px.shifty                          = cache_gpu. pos_px. shifty - cache_gpu. pos_feeback_coeffient_y.*(cache_gpu.sy - mean(cache_gpu.sy));
        cache_gpu.pos_px.shiftx                          = cache_gpu. pos_px. shiftx - cache_gpu. pos_feeback_coeffient_x.*(cache_gpu.sx - mean(cache_gpu.sx));
        %-------------------------------------
        %update feedback coefficient x
        u                                                = cache_gpu.sx      - mean(cache_gpu.sx);
        v                                                = cache_gpu.last_sx - mean(cache_gpu.last_sx);
        e1                                               = sqrt(sum(u.*u));
        e2                                               = sqrt(sum(v.*v));
        if e1*e2 > 1e-9 && max(u) > 1e-4 && max(v) > 1e-4
            c = sum(u.*v)/e1/e2;
            if c>0.5,cache_gpu. pos_feeback_coeffient_x  = 1.1*cache_gpu. pos_feeback_coeffient_x; end
            if c<0.5,cache_gpu. pos_feeback_coeffient_x  = 0.85*cache_gpu. pos_feeback_coeffient_x; end
        end
        %update feedback coefficient y
        u                                                = cache_gpu.sy      - mean(cache_gpu.sy);
        v                                                = cache_gpu.last_sy - mean(cache_gpu.last_sy);
        e1                                               = sqrt(sum(u.*u));
        e2                                               = sqrt(sum(v.*v));
        if e1*e2                                         > 1e-9 && max(u)>1e-4 && max(v)>1e-4
            c                                            = sum(u.*v)/e1/e2;
            if c>0.5,cache_gpu. pos_feeback_coeffient_y  = 1.1*cache_gpu. pos_feeback_coeffient_y; end
            if c<0.5,cache_gpu. pos_feeback_coeffient_y  = 0.85*cache_gpu. pos_feeback_coeffient_y; end
        end
        cache_gpu.last_sx                                = cache_gpu.sx;
        cache_gpu.last_sy                                = cache_gpu.sy;
    end
end


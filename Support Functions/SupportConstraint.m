%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [wavefront_supp_rear] = SupportConstraint(wavefront_supp_front,support)
    wavefront_supp_rear        = wavefront_supp_front.*support;
end


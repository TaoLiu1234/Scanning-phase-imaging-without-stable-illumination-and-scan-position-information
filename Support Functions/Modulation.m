%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [wavefront_modu_rear] = Modulation(wavefron_modu_front,modulator)
    wavefront_modu_rear        = wavefron_modu_front.*modulator;
end


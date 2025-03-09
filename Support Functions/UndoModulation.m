%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 25/2/2023
%--------------------------------------------------------------------------

function [wavefront_modu_front_new] = UndoModulation(wavefront_modu_front,modulator,wavefront_modu_rear,inty_modu,alpha_max_inty_modu,alpha)
%for calibrated modulator and faster calculation
%     wavefront_modu_front_new        = wavefront_modu_front.*(1-alpha_max_inty_modu.*inty_modu) + alpha_max_inty_modu.*wavefront_modu_rear.*conj(modulator);
    
           wavefront_modu_front_new = wavefront_modu_front + alpha./max(max(modulator.*conj(modulator))).*conj(modulator).*(wavefront_modu_rear - wavefront_modu_front.*modulator);
%     wavefront_modu_front_new = wavefront_modu_front + alpha.*conj(modulator).*(wavefront_modu_rear - wavefront_modu_front.*modulator);
end


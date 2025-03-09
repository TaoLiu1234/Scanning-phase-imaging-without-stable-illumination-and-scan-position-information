%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 14/4/2023
%--------------------------------------------------------------------------

function [ updated_modulator ]      = UpdateModulator( wf_front,wf_rear,modulator,update_method,alpha_modu )
    switch update_method
        case 'AVG'
%             updated_modulator       = sum(wf_rear.*conj(wf_front),3)./(sum(wf_front.*conj(wf_front),3) + eps);
            updated_modulator       = modulator + 1.*conj(mean(wf_front,3))./max(max(abs(conj(mean(wf_front,3))).^2)).*(mean(wf_rear - wf_front.*modulator,3));
            amp_updated_modulator   = abs(updated_modulator);
            amp_updated_modulator(amp_updated_modulator>1)   = 1;%constraint of the transmission function
            amp_updated_modulator(amp_updated_modulator<0.1) = 0.1;
            updated_modulator       = ( updated_modulator./abs(updated_modulator).*amp_updated_modulator);

%             updated_modulator = modulator + 1.*sum(conj(wf_front),3)./max(max(abs(sum(conj(wf_front),3).^2))).*(sum(wf_rear.*conj(wf_front),3) - modulator);
        case 'PIE'
            conj_wf_front           = conj(wf_front);
            inty_obj2               = wf_front.*conj_wf_front;
            alpha                   = 0.9/max(max(inty_obj2));
            updated_modulator       = mean(modulator.*(1 - alpha.*inty_obj2) + alpha.*wf_rear.*conj_wf_front,3);
    end
end


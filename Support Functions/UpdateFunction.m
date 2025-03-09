%--------------------------------------------------------------------------
%Author: Taoliu
%Date: 6/3/2023
%--------------------------------------------------------------------------

function [obj1]         = UpdateFunction(update_method,obj1,obj2,exit_wave_new,exit_wave,alpha)
    switch update_method
        case 'PIE'
            cobj2       = conj(obj2);
            inty_obj2   = obj2.*cobj2;
            alpha_max   = alpha/max(max(inty_obj2));
            obj1        = obj1.*(1 - alpha_max.*inty_obj2) + alpha_max.*exit_wave_new.*cobj2;
        case 'ePIE'
            obj1        = obj1 + alpha.*conj(obj2)./max(max(abs(conj(obj2)).^2)).*(exit_wave_new - exit_wave);
        case 'AVG'
            obj1        = obj1 + 1.*conj(mean(obj2,3))./max(max(abs(conj(mean(obj2,3))).^2)).*(mean(exit_wave_new - exit_wave,3));
    end

end


%--------------------------------------------------------------------------
%Author: Fucai Zhang, Tao Liu
%Date: 28/1/2015  15/4/2023
%--------------------------------------------------------------------------
function handles     = Display(mode, probe_guess, object_guess,modulator_guess, it,it_total,varargin)
% Create the main display figure...
switch mode
    case 'Initiate'
        ssize        = get(0,'MonitorPositions');
        ssize        = ssize(end,:);
        fig_size     = floor(ssize(4)*.7);
        fig_offset_y = floor(ssize(4)*.1);
        fig_offset_x = floor(ssize(4)*.3);
        handles(7)   = figure('Position', [fig_offset_x fig_offset_y   fig_size  fig_size], ...
            'Name', 'Reconstruction starting ... ');
        % Reconstructed first guess modulus axes
        handles(1)   = imagesc(abs(gather(probe_guess)),'Parent',subplot(231));
        colormap(gray)
        title('Probe Modulus');
        axis image off;

        y            = size(probe_guess,1)*0.1;
        x            = y;
        ysep=y*0.5;
        handles(8)   = text(x,y, '','Fontsize',11, 'Color', 'g');
        handles(9)   = text(x,y+ysep, '','Fontsize',11, 'Color', 'g');
        handles(10)   = text(x,y+ysep*2, '','Fontsize',11, 'Color', 'g');

        % Reconstructed second guess modulus axes
        handles(2)   = imagesc(abs(gather(object_guess)),'Parent',subplot(232));
        colormap gray;
        title('Object Modulus');
        axis image off;

        % Reconstructed first guess phase axes
        handles(3)   = imagesc(abs(gather(modulator_guess)),'Parent',subplot(233));
        title('Modulator Modulus');
        axis image off;

        % Reconstructed second guess phase axes
        handles(4)   = imagesc(angle(gather(probe_guess)),'Parent',subplot(234));
        title('Probe Phase');
        axis image off;

        handles(5)   = imagesc(angle(gather(object_guess)),'Parent',subplot(235));
        title('Object Phase');
        axis image off;
        
        handles(6)   = imagesc(angle(gather(modulator_guess)),'Parent',subplot(236));
        title('Modulator Phase');
        axis image off;

        drawnow;
    case 'Update'
        handles         = varargin{1};
        probe_guess     = gather(probe_guess);
        object_guess    = gather(object_guess);
        modulator_guess = gather(modulator_guess);
        set(handles(1),'CData',abs(probe_guess))
        set(handles(2),'CData',abs(object_guess))
        set(handles(3),'CData',abs(modulator_guess));
        set(handles(4),'CData',angle(probe_guess));
        set(handles(5),'CData',angle(object_guess));
        set(handles(6),'CData',angle(modulator_guess));

        set(handles(7), 'name', ['Reconstruction in progress ...  (', num2str(it),'/',num2str(it_total),')']);
        drawnow;
        set(handles(8),'String',['iteration no: ',num2str(it),'/',num2str(it_total)]);
end
end
%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 15/06/2015  
%Note: call: handles      = ShowReconstruction(guess, title_string)
% or handles         = ShowReconstruction(first_guess, second_guess, title_string)
% show magnitude and phase of wavefront(s)

% fucai
%--------------------------------------------------------------------------

function handles     = ShowReconstruction(first_guess, varargin)

title_string         = 'reconstruction';
no_subplot           = 'two';
if nargin            == 2
    if  isnumeric(varargin{1})
        second_guess = varargin{1};
        no_subplot   = 'four';
    else
        title_string = varargin{1};
    end
end
if  nargin           == 3
    title_string     = varargin{2};
end
ssize                = get(0,'MonitorPositions');
ssize                = ssize(end,:);
fig_offset           = round(ssize(4)*.05);
        
switch  no_subplot
    case 'two'
       fig_size      = min(round(ssize(4)*.5), size(first_guess,1));

        handles(1)   = figure('Position', [fig_offset*1.3 fig_offset   2*fig_size  fig_size], ...
            'Name', title_string);
         % modulus axes
        handles(2)   = imagesc(abs(first_guess),'Parent',subplot(121));
        colormap(gray)
        title('Amplitude');   axis image off;
        
        % phase axes
        handles(3)   = imagesc(angle(first_guess),'Parent',subplot(122));
        colormap gray;
        title('Phase');  axis image off;
        
    case 'four'
        fig_size     = min(round(ssize(4)*.75), 2.3*max(size(first_guess,1),size(second_guess,1)));
        handles(1)   = figure('Position', [fig_offset*2 fig_offset   fig_size  fig_size], ...
            'Name', title_string);
        
        % first guess modulus axes
        handles(2)   = imagesc(abs(first_guess),'Parent',subplot(221));
        colormap(gray)
        title('Probe\_guess Amplitude');
        axis image off;
        
        %Reconstructed first guess phase axes
        handles(3)   = imagesc(angle(first_guess),'Parent',subplot(222));
        title('Probe\_guess Phase');
        axis image off;
        
        %Reconstructed second guess modulus axes
        handles(4)   = imagesc(abs(second_guess),'Parent',subplot(223));
        colormap gray;
        title('Object\_guess Amplitude');
        axis image off;
        
       
        %Reconstructed second guess phase axes
        handles(5)   = imagesc(angle(second_guess),'Parent',subplot(224));
        title('Object\_guess Phase');
        axis image off;
        drawnow;
end
end

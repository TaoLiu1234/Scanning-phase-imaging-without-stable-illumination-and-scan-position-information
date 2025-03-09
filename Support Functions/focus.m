%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 15/06/2015
%--------------------------------------------------------------------------
function [wf_out, dx] = focus(wf, px, z0, step,wavelength, method,varargin)
% call: InteractiveFocus(wf, px, z, step,wavelength,method)
% all length has the same unit (mm or um).
% method {'AS', 'Fresnel'}
% [anchor_pos, anchor_phase]

% fucai, Sheffield

if nargin <6
    method = 'AS';
end
if nargin <7
    anchor = [1, -pi/2];
else
    anchor = varargin{1};
end 

if nargin <8
    refocus = 1;
else
    refocus = varargin{2};
end 

dx = px;
wf_out = wf;

z = z0;

switch method
    case 'AS'
        [wf_out, dx] = AngularSpectrum(wf, px/wavelength, z/wavelength);
    case 'Fresnel'
        [wf_out, dx] = Fresnel(wf, px/wavelength, z/wavelength);
end

h = ShowReconstruction(wf_out, 0, step, method, anchor);
h0 = h{1};

while refocus
    try
        if waitforbuttonpress(); % key is pressed
            switch get(h0,'CurrentCharacter');
                case 43             % +
                    step = step*2;
                case 45             % -
                    step = step/2;
                case {29}       % right arrow
                    z = z + step;
                case {28}       % left arrow
                    z = z - step;
                case {27, 13}      % esc or q
                    break;
                case {8, 127}       % back, delete
                    z = z0;
                otherwise
                    continue;
            end
        else             % click mouse button
            switch get(h0, 'SelectionType');
                case 'normal'       % left button
                    z = z-step;
                case 'alt'          % right button
                    z = z+step;
                case 'extend'       % middle button, wheel
                    break;
            end
        end
        
        switch method
            case 'AS'
                [wf_out, dx] = AngularSpectrum(wf, px/wavelength, z/wavelength);
            case 'Fresnel'
                [wf_out, dx] = Fresnel(wf, px/wavelength, z/wavelength);
        end
        dx = dx*wavelength;
        UpdateReconFigure(h, wf_out, z, step, method, anchor);

    catch me
        disp('figure deleted by user!');
        break;
    end
end
end

function [wf_out, px] = Fresnel(wf_in,dx, dis)
% usage: [wf_out, px_out] = FresnelProp(wf_in,px_in, dis)
% dis, px_in, px_out are propagation distance and sampling intervals in unit of
% wavelength. 

% formular: int{wf_in *exp(ik*(x^2+y^2)/z)*exp(-2i*pi*(x*x'+y*y'))dxdy } <--
% obeys to the convention of Goodman's book 
% fast version with fftshift implemented by matrix mulitiplication. 

% note, wrong doc of fft in Matlab. 
% fft is with kernal exp(-2ipi*n*k)

% fucai, Sheffield, 30/12/2010

%% fast code 
[M,N]= size(wf_in);
M2 = floor(M/2);
N2 = floor(N/2);

px = dx;
px(1) = dis /dx(1)/N;
px(end) = dis /dx(end)/M;

dx2 = dx.^2;
px2 = px.^2;

m = (-M2: -M2+M-1).';
n = (-N2: -N2+N-1);

mm = m.^2;
nn = n.^2;

if dis == 0
    wf_out = wf_in;
    px = dx;
elseif dis > 0
    H_in = exp(1i*pi/dis*mm*dx2(end)+2i*pi*(m+M2)*M2/M) * ...
        exp(1i*pi/dis*nn*dx2(1)+2i*pi*(n+N2)*N2/N);
    
    H_out = exp(1i*pi/dis*mm*px2(end) + 2i*pi*(m+M2)*M2/M) * ...
        exp(1i*pi/dis*nn*px2(1) + 2i*pi*(n+N2)*N2/N);
    K = exp(-2i*pi/M*M2*M2 - 2i*pi/N*N2*N2);
    
    wf_out = K*H_out.*fft2(H_in.*wf_in)/sqrt(M*N);
else
    H_in = exp(1i*pi/dis*mm*dx2(end)-2i*pi*(m+M2)*M2/M) * ...
        exp(1i*pi/dis*nn*dx2(1)-2i*pi*(n+N2)*N2/N);
    
    H_out = exp(1i*pi/dis*mm*px2(end) - 2i*pi*(m+M2)*M2/M) * ...
        exp(1i*pi/dis*nn*px2(1) - 2i*pi*(n+N2)*N2/N);
    K = exp(2i*pi/M*M2*M2 + 2i*pi/N*N2*N2);
    
    wf_out = K* H_out.*ifft2(H_in.*wf_in)*sqrt(M*N);
end
px = abs(px);
end

function [wf_out, px] = AngularSpectrum(wf_in, px, dis)
% usage: wf_out = AngularSpectrum(wf_in,dis, px)
% dis and px are propagation distance and sampling interval in unit of
% wavelength. 

% fucai, Sheffield, 30/12/2010

[m,n]=size(wf_in);
m2 = ceil(m/2);
n2 = ceil(n/2);
u = [0:m2-1 m2-m:-1]/px(1)/m;
v = [0:n2-1 n2-n:-1]/px(end)/n;
[fx,fy] = meshgrid(u,v);

H = exp(2i*pi*dis*sqrt(1-fx.^2-fy.^2));
wf_out = ifft2(H.*fft2(wf_in));
end

function handles = ShowReconstruction(first_guess, z, step, method, anchor)

title_string = ['refocus by ', method, ' method @ ', num2str(z), ' (step = ', num2str(step),')'];

ssize = get(0,'MonitorPositions');
ssize = ssize(end,:);
fig_offset = round(ssize(4)*.02);

fig_size = min(round(ssize(4)/2.5), 1*size(first_guess,1));

handles{1} = figure('Position', [fig_offset fig_offset   2*fig_size  fig_size], ...
    'Name', title_string);
% modulus axes
handles{2} = imagesc(abs(first_guess),'Parent',subplot(121));
colormap(gray)
title('Modulus');   axis image off;

% phase axes
phase = angle(first_guess*conj(first_guess(anchor(1),anchor(1)))*exp(1i*anchor(2)));
handles{3} = imagesc(phase,'Parent',subplot(122));
colormap gray;
title('Phase');  axis image off;

end

function UpdateReconFigure(handles,first_guess, z, step, method, anchor)
a = abs(first_guess);
phase = angle(first_guess*conj(first_guess(anchor(1),anchor(1)))*exp(1i*anchor(2)));
set(handles{1}, 'name', ['refocus by ', method, ' method @ ', num2str(z), ' (step = ', num2str(step),'); max amp; ', num2str(max(a(:)))]);
set(handles{2},'CData', a);
set(handles{3},'CData',phase);
drawnow;

end

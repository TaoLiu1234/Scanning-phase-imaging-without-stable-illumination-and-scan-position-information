%--------------------------------------------------------------------------
%Author: Fucai Zhang
%Date: 28/1/2015
%Note: generate an alternating 0, 1 sequence for algoritm control in CMI
% 0: use current revised exit wave behind modualtor for Modulus constrait 
% 1: use 2* current - previous (like Difference Map)
% sv: starting value
% t1, length of starting value
% t2, interval of altering value
% t3, interval of starting value 
% s0, index after that (exclusive) seq is set to zero. (ALG -> HIO modulus updating 

% 2015/01/28
% F. Zhang
%--------------------------------------------------------------------------

function seq        = AlgSeqGen(no_iters,start , t1, t2, t3, s0)

if ischar(start) 
    switch upper(start)
        case {'HIO-TYPE', 0}
            sv      = 0;
        case { 'DM-TYPE', 1}
            sv      = 1;
        otherwise
            error('Alg can only be "HIO-type", or "DM-type"');
    end
else
    if ~any(start   == [0,1])
        error('start value can only be 0 or 1');
    end
    sv              = start;
end
        
if nargin           < 6
    s0              = no_iters;
    if nargin       < 5
        t3          = t2;
    end
end

rep                 = ceil(no_iters/(t2+t3));

seq(1:t2)           = 1-sv;
seq(t2+1: t2+t3)    = sv;
seq                 = repmat(seq,[1, rep]);
seq                 = [sv*ones(1,t1), seq];

seq                 = seq(1:no_iters);
if s0               < no_iters
    seq(s0+1:end)   = 0;
end
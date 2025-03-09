%--------------------------------------------------------------------------
%Author: MICHAL ODSTRCIL
%Date: 25/2/2023
%Open source code from the paper "Iterative least-squares solver for generalized maximum-likelihood ptychography"
%DOI:https://doi.org/10.1364/OE.26.003108
%--------------------------------------------------------------------------

function ProgressBar(n,N,w,x_coefficient,y_coefficient,show_results_every)

    if nargin       < 3
        w           = 20;
    end
    
    % progress char
    cprog           = '.';
    cprog1          = '*';
    % begining char
    cbeg            = '[';
    % ending char
    cend            = ']';
    
    p               = min( floor(n/N*(w+1)), w);
    
    persistent  pprev;
    persistent  ps_previous;
    if isempty(pprev)
        pprev       = -1;
    end
    
    if not(p        == pprev)
        ps          = repmat(cprog, [1 w]);
        ps(1:p)     = cprog1;
        ps          = [cbeg ps cend ,'x and y pos coefficient(avg)', num2str(x_coefficient,'%.4f'),' & ',num2str(y_coefficient,'%.4f')];
        if n        ~= show_results_every
            % clear previous string
            fprintf( repmat('\b', [1 length(ps_previous)]) );
        end
        fprintf(ps);
        ps_previous = ps;
    end
    pprev           = p;
    
    if n            == N
        fprintf('\n');
    end

end
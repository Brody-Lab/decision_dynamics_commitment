function [aa nf] = naninterp(x, wrap, tol)
% interpolates points in x marked by 'NaN'
% 0 and wrap are identified as the same coordinate (within tol)
if nargin < 3, tol = 30; end;

x = rowvec(x);
nans = find(isnan(x));
if isempty(nans), aa = x; return; end;

starting_nans = [nans(1) nans(find(diff(nans) > 1) + 1)];
ending_nans   = [nans(diff(nans) > 1) nans(end)];

not_fixed = [];
for i = 1:numel(starting_nans);
    if starting_nans(i)-1 > 0 && ending_nans(i)+1 <= length(x),
        jump = x(ending_nans(i)+1) - x(starting_nans(i)-1);

        if abs(jump) > wrap-tol,  % if it looks like we just wrapped around
            not_fixed = [not_fixed starting_nans(i):ending_nans(i)]; %#ok<AGROW>
        else
            Dt = ending_nans(i) - starting_nans(i) + 2;
            dx = jump/Dt;
            
            if dx == 0,
                newvalues = x(starting_nans(i)-1) * ones(1, Dt+1);
            else
                newvalues = x(starting_nans(i)-1):dx:x(ending_nans(i)+1);
            end
            
            write_idx=starting_nans(i)-1:ending_nans(i)+1;
            
            if numel(newvalues)~=numel(write_idx)
                keyboard
            end
            
            x(starting_nans(i)-1:ending_nans(i)+1) = newvalues;
        end
    end
end
     

if nargout > 0, 
    aa = x; 
    nf = not_fixed;
end;